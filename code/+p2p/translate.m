function translatedImage = translate(p2pModel, inputImage, varargin)
% translate    Apply a generator to an image.
%
% Args:
%   p2pModel    - struct containing a pix2pix generator as produced by the
%                 output of p2p.train
%   inputImage  - Input image to be translated
%   
%   translate also accepts the following Name-Value pairs:
%
%       ExecutionEnvironment - What processor to use for image translation,
%                              "auto", "cpu", or, "gpu" (default: "auto")
%       ARange               - Maximum numeric value of input image, used
%                              for input scaling (default: 255)
%   
% Returns:
%   translatedImage - Image translated by the generator model
%
% Note:
%   The input image must be a suitable size for the generator model
%
% See also: p2p.train
    
% Copyright 2020 The MathWorks, Inc.
    
    options = parseInputs(varargin{:});
    
    inputClass = class(inputImage);
    
    networkInput = prepImageForNetwork(inputImage, options);
    out = tanh(p2pModel.g.forward(networkInput));
    
    % Make the output match the input
    translatedImage = (extractdata(out) + 1)/2;
    if strcmp(inputClass, "uint8")
        translatedImage = uint8(255*translatedImage);
    else
        translatedImage = cast(translatedImage, "like", inputImage);
    end

end

function options = parseInputs(varargin)
    % Parse name value pair arguments
    parser = inputParser();
    parser.addParameter("ExecutionEnvironment", "auto", ...
        @(x) ismember(x, ["auto", "cpu", "gpu"]));
    parser.addParameter("ARange", 255, ...
        @(x) validateattributes(x, "numeric", "positive"));
    
    parser.parse(varargin{:});
    options = parser.Results;
end

function networkInput = prepImageForNetwork(inputImage, options)
    % cast to single, scale and put on the gpu as appropriate
    networkInput = 2*single(inputImage)/options.ARange - 1;
    if (options.ExecutionEnvironment == "auto" && canUseGPU) || ...
            options.ExecutionEnvironment == "gpu"
        networkInput = gpuArray(networkInput);
    end
    networkInput = dlarray(networkInput, 'SSCB');
end