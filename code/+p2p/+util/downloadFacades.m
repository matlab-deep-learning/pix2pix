function [aFolder, bFolder] = downloadFacades(destination)
% downloadFacades Saves a copy of the facades dataset images.
%
% Inputs:
%   destination - Location to save dataset to (default: "./datasets/facades")
% Returns:
%   aFolder - Location of label images
%   bFolder - Location of target images

% Copyright 2020 The MathWorks, Inc.

    if nargin < 1
        destination = "./datasets/facades";
    end
    
    aFolder = fullfile(destination, "A");
    bFolder = fullfile(destination, "B");

    if ~isfolder(destination)
        mkdir(destination);
        mkdir(aFolder);
        mkdir(bFolder);
    end

    dataUrl = "http://cmp.felk.cvut.cz/~tylecr1/facade/CMP_facade_DB_base.zip";
    tempZipFile = tempname;
    tempUnzippedFolder = tempname;
    fprintf("Downloading facades dataset...")
    websave(tempZipFile, dataUrl);
    fprintf("done.\n")
    
    fprintf("Extracting zip...")
    unzip(tempZipFile, tempUnzippedFolder);
    fprintf("done.\n")
    
    
    % Labels are indexed pngs
    movefile(fullfile(tempUnzippedFolder, "base", "*.png"), aFolder);
    % Convert them all to RGB
    convertToRgb(aFolder);
    
    % Photos are RGB jpgs
    movefile(fullfile(tempUnzippedFolder, "base", "*.jpg"), bFolder);
            
    fprintf("done.\n")
    
end

function convertToRgb(directory)
    % Converts all the images in the directory to RGB.
    ims = imageDatastore(directory);
    for iIm = 1:numel(ims.Files)
        filename = ims.Files{iIm};
        [im, map] = imread(filename);
        rgbIm = ind2rgb(im, map);
        imwrite(rgbIm, filename);
    end
end