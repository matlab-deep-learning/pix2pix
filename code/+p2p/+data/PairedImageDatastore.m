classdef PairedImageDatastore < matlab.io.Datastore & ...
                                matlab.io.datastore.Shuffleable & ...
                                matlab.io.datastore.MiniBatchable
% PairedImageDatastore A datastore to provide pairs of images.
%
%   This datastore allows mini-batching and shuffling of matching pairs of
%   images in two folders while, preserving the pairing of images.

% Copyright 2020 The MathWorks, Inc.

    properties (Dependent)
        MiniBatchSize
    end
    
    properties (SetAccess = protected)
        DirA
        DirB
        ImagesA
        ImagesB
        NumObservations
        MiniBatchSize_
        Augmenter
        PreSize
        CropSize
        ARange
        BRange
    end
     
    methods (Static)
        function [inputs, remaining] = parseInputs(varargin)
            parser = inputParser();
            % Remaining inputs should be for the imageAugmenter
            parser.KeepUnmatched = true;
            parser.addParameter('PreSize', [256, 256]);
            parser.addParameter('CropSize', [256, 256]);
            parser.addParameter('ARange', 255);
            parser.addParameter('BRange', 255);
            parser.parse(varargin{:});
            inputs = parser.Results;
            remaining = parser.Unmatched;
        end
    end
    
    methods
        function obj = PairedImageDatastore(dirA, dirB, miniBatchSize, varargin)
            % Create a PairedImageDatastore
            %
            % Args:
            %   dirA            - directory or cell array of filenames
            %   dirB            - directory or cell array of filenames
            %   miniBatchSize   - Number of image pairs to provide in each
            %                       minibatch
            % TODO list optional name-value pairs PreSize, CropSize,
            % Mirror
            %
            % Note:
            %   This datastore relies on the naming of image files in the
            %   two directory to appear in the same ordering for correct
            %   pairing. The simplest way to ensure this is if pairs of
            %   images both have the same name.
            
            includeSubFolders = true;
            
            obj.DirA = dirA;
            obj.DirB = dirB;
            obj.ImagesA = imageDatastore(obj.DirA, "IncludeSubfolders", includeSubFolders);
            obj.ImagesB = imageDatastore(obj.DirB, "IncludeSubfolders", includeSubFolders);
            obj.MiniBatchSize = miniBatchSize;
            
            assert(numel(obj.ImagesA.Files) == numel(obj.ImagesB.Files), ...
                    'p2p:datastore:notMatched', ...
                    'Number of files in A and B folders do not match');
            obj.NumObservations = numel(obj.ImagesA.Files);
            
            % Handle optional arguments
            [inputs, remaining] = obj.parseInputs(varargin{:});
            
            obj.ARange = inputs.ARange;
            obj.BRange = inputs.BRange;
            obj.Augmenter = imageDataAugmenter(remaining);
            obj.PreSize = inputs.PreSize;
            obj.CropSize = inputs.CropSize;
            
        end
        
        function tf = hasdata(obj)
            tf = obj.ImagesA.hasdata() && obj.ImagesB.hasdata();
        end
        
        function data = read(obj)
            imagesA = obj.ImagesA.read();
            imagesB = obj.ImagesB.read();
            
            % for batch size 1 imagedatastore doesn't wrap in a cell
            if ~iscell(imagesA)
                imagesA = {imagesA};
                imagesB = {imagesB};
            end
           [transformedA, transformedB] = ...
                p2p.data.transformImagePair(imagesA, imagesB, ...
                                            obj.PreSize, obj.CropSize, ...
                                            obj.Augmenter);
            [A, B] = obj.normaliseImages(transformedA, transformedB);
            data = table(A, B);
        end
        
        function reset(obj)
            obj.ImagesA.reset();
            obj.ImagesB.reset();
        end
        
        function objNew = shuffle(obj)
            objNew = obj.copy();
            numObservations = objNew.NumObservations;
            objNew.ImagesA = copy(obj.ImagesA);
            objNew.ImagesB = copy(obj.ImagesB);
            idx = randperm(numObservations);
            
            objNew.ImagesA.Files = objNew.ImagesA.Files(idx);
            objNew.ImagesB.Files = objNew.ImagesB.Files(idx);
        end
        
        function [aOut, bOut] = normaliseImages(obj, aIn, bIn)
            aOut = cellfun(@(x) 2*(single(x)/obj.ARange) - 1, aIn, 'UniformOutput', false);
            bOut = cellfun(@(x) 2*(single(x)/obj.BRange) - 1, bIn, 'UniformOutput', false);
        end
        
        function val = get.MiniBatchSize(obj)
            val = obj.MiniBatchSize_;
        end
        
        function set.MiniBatchSize(obj, val)
            obj.ImagesA.ReadSize = val;
            obj.ImagesB.ReadSize = val;
            obj.MiniBatchSize_ = val;
        end
    end
end