classdef DatastoreTests < tests.WithWorkingDirectory
% Tests for the custom PairedImageDatastore

% Copyright 2020 The MathWorks, Inc.
    
    properties (TestParameter)
        miniBatchSize = {1, 2, 3}
    end
    
    methods (Test)
        function testReadData(test, miniBatchSize)
            ds = p2p.data.PairedImageDatastore(fullfile(test.Resources, 'imagePairs', 'A'), ...
                                            fullfile(test.Resources, 'imagePairs', 'B'), miniBatchSize);
            data = ds.read();
            test.verifyEqual(size(data), [miniBatchSize, 2]);
            test.verifyClass(data, 'table');
        end
        
        function testReset(test)
            ds = p2p.data.PairedImageDatastore(fullfile(test.Resources, 'imagePairs', 'A'), ...
                                            fullfile(test.Resources, 'imagePairs', 'B'), 1);
            data1 = ds.read();
            ds.reset();
            data2 = ds.read();
            
            test.verifyEqual(data1, data2);
        end
        
        function testUnpairable(test)
            makeDatastore = @() p2p.data.PairedImageDatastore(fullfile(test.Resources, 'badImagePairs', 'A'), ...
                                            fullfile(test.Resources, 'badImagePairs', 'B'), 1);
            test.verifyError(makeDatastore, 'p2p:datastore:notMatched')
        end
        
        function testSetMiniBatchSize(test)
            newMiniBatchSize = 3;
            ds = p2p.data.PairedImageDatastore(fullfile(test.Resources, 'imagePairs', 'A'), ...
                                            fullfile(test.Resources, 'imagePairs', 'B'), 1);
            ds.MiniBatchSize = newMiniBatchSize;
            data = ds.read();
            test.verifyEqual(size(data), [newMiniBatchSize, 2]);
        end
        
        function testOptionalArgs(test)
            cropSize = [64, 64];
            ds = p2p.data.PairedImageDatastore(fullfile(test.Resources, 'imagePairs', 'A'), ...
                                            fullfile(test.Resources, 'imagePairs', 'B'), 1, ...
                                            "PreSize", [128, 128], ...
                                            "CropSize", cropSize,...
                                            "RandXReflection", false);
            
            data = ds.read();
            
            test.verifyEqual(size(data{1,1}{1}), [cropSize, 3]);
            test.verifyEqual(size(data{1,2}{1}), [cropSize, 3]);
        end
        
        function testAugmenter(test)
            ds = p2p.data.PairedImageDatastore(fullfile(test.Resources, 'imagePairs', 'A'), ...
                                            fullfile(test.Resources, 'imagePairs', 'B'), 1, ...
                                            "RandRotation", [0, 360]);
            data1 = ds.read();
            ds.reset();
            data2 = ds.read();
            
            test.verifyNotEqual(data1, data2);
        end
        
    end
    
end