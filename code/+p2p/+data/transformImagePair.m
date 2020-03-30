function [transformedA, transformedB] = transformImagePair(imagesA, imagesB, preSize, cropSize, augmenter)
% transformImagePair    Apply a matching set of transformations to images
%
% Args:
%   imagesA     - cell array of images to transform
%   imagesB     - cell array of images to transform
%   preSize     - [1x2] dimensions to initially resize image to
%   cropSize    - [1x2] dimensions to crop image to
%   augment     - imageDataAugmenter to use for image transforms
%
% Returns:
%   transformedA - cell array of transformed images A
%   transformedB - cell array of transformed images B

% Copyright 2020 The MathWorks, Inc.

    % Default to identity transform
    transformedA = imagesA;
    transformedB = imagesB;
    
    % Apply a resize opertion
    if ~isempty(preSize)
        transformedA = cellfun(@(im) imresize(im, preSize), ...
                                transformedA, ...
                                'UniformOutput', false);
        transformedB = cellfun(@(im) imresize(im, preSize), ...
                                transformedB, ...
                                'UniformOutput', false);
    end
    
    % Apply the imageDataAugmenter
    if ~isempty(augmenter)
        [transformedA, transformedB] = augmenter.augmentPair(transformedA, transformedB);
    end
    
    % Apply a random crop
    if ~isempty(cropSize)
        [transformedA, transformedB] = randCrop(transformedA, transformedB, cropSize);
    end
    
end

function [imOut1, imOut2] = randCrop(im1, im2, cropSize)
    rect = augmentedImageDatastore.randCropRect(im1, cropSize);
    doCrop = @(im) augmentedImageDatastore.cropGivenDiscreteValuedRect(im, rect);
    imOut1 = cellfun(doCrop, im1, 'UniformOutput', false);
    imOut2 = cellfun(doCrop, im2, 'UniformOutput', false);
    
end