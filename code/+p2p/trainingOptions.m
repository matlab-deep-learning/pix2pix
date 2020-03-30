function options = trainingOptions(varargin)
% trainingOptions    Create options struct for training pix2pix model
%
%   By default the struct will contain parameters which are close to those
%   described in the original pix2pix paper. To change any parameters
%   either modify the struct after creation, or pass in Name-Value pairs to
%   this function.
%
%   trainingOptions accepts the following Name-Value pairs:
%       
%       ExecutionEnvironment - What processor to use for image translation:
%                              "auto", "cpu", or, "gpu" (default: "auto")
%       InputChannels        - Number of channels in the input image 
%                              (default: 3)
%       OutputChannels       - Number of channels in the target image 
%                              (default: 3)
%       MiniBatchSize        - MiniBatch size during training (default: 1)
%       RandXReflection      - Whether to apply horizontal flipping data 
%                              augmentation (default: true)
%       PreSize              - Dimensions to initially resize image to 
%                              (before cropping) (default: [286, 286])
%       InputSize            - Dimension to crop images to 
%                              (default: [256, 256])
%       ARange               - Maximum numeric value of input images 
%                              (default: 255)
%       BRange               - Maximum numeric value of target images 
%                              (default: 255)
%       ResumeFrom           - File path to resume training from checkpoint
%                              (default: [])
%       GLearnRate           - Learn rate of the generator's optimizer 
%                              (default: 0.0002)
%       GBeta1               - Beta 1 parameter of the generator's 
%                              optimizer(default: 0.5)
%       GBeta2               - Beta 2 parameter of the generator's 
%                              optimizer(default: 0.999)
%       DLearnRate           - Learn rate of the discriminator's optimizer 
%                              (default: 0.0002)
%       DBeta1               - Beta 1 parameter of the discriminator's 
%                              optimizer(default: 0.5)
%       DBeta2               - Beta 2 parameter of the discriminator's 
%                              optimizer(default: 0.999)
%       MaxEpochs            - Total epochs for training (default: 200)
%       CheckpointPath       - Path to a folder to save checkpoints to 
%                              (default: "checkpoints")
%       DRelLearnRate        - Relative scaling factor for the 
%                              discriminator's loss (default: 0.5)
%       Lambda               - Relative scaling factor for the L1 loss 
%                              (default: 100)
%       GDepth               - Depth of the generator (default: 8)
%       DDepth               - Depth of the discriminator (default: 4)
%       Verbose              - Whether to print status to command line 
%                              (default: true)
%       VerboseFrequency     - Frequency of plot and command line update in
%                              iterations (default: 50)
%       Plots                - Plot type to show during training: "none" or
%                              "training-progress" (default: "training-progress")
%
% See also: p2p.train

% Copyright 2020 The MathWorks, Inc.
    
    parser = inputParser();
    
    parser.addParameter("ExecutionEnvironment", "auto", ...
        @(x) ismember(x, ["auto", "cpu", "gpu"]));
    parser.addParameter("InputChannels", 3, ...
        @(x) validateattributes(x, "numeric", ["scalar","integer","positive"]));
    parser.addParameter("OutputChannels", 3, ...
        @(x) validateattributes(x, "numeric", ["scalar","integer","positive"]));
    parser.addParameter("MiniBatchSize", 1, ...
        @(x) validateattributes(x, "numeric", ["scalar","integer","positive"]));
    parser.addParameter("RandXReflection", true, ...
        @(x) validateattributes(x, "logical", "scalar"));
    parser.addParameter("PreSize", [286, 286], ...
        @(x) validateattributes(x, "numeric", ["positive", "integer"]));
    parser.addParameter("InputSize", [256, 256], ...
        @(x) validateattributes(x, "numeric", ["positive", "integer"]));
    parser.addParameter("ARange", 255, ...
        @(x) validateattributes(x, "numeric", "positive"));
    parser.addParameter("BRange", 255, ...
        @(x) validateattributes(x, "numeric", "positive"));
    parser.addParameter("ResumeFrom", [], ...
        @(x) validateattributes(x, ["char", "string"], "scalartext"));
    parser.addParameter("GLearnRate", 0.0002, ...
        @(x) validateattributes(x, "numeric", "scalar"));
    parser.addParameter("GBeta1", 0.5, ...
        @(x) validateattributes(x, "numeric", "scalar"));
    parser.addParameter("GBeta2", 0.999, ...
        @(x) validateattributes(x, "numeric", "scalar"));
    parser.addParameter("DLearnRate", 0.0002, ...
        @(x) validateattributes(x, "numeric", "scalar"));
    parser.addParameter("DBeta1", 0.5, ...
        @(x) validateattributes(x, "numeric", "scalar"));
    parser.addParameter("DBeta2", 0.999, ...
        @(x) validateattributes(x, "numeric", "scalar"));
    parser.addParameter("MaxEpochs", 200, ...
        @(x) validateattributes(x, "numeric", ["scalar","integer","positive"]));
    parser.addParameter("CheckpointPath", "checkpoints", ...
        @(x) validateattributes(x, ["char", "string"], "scalartext"));
    parser.addParameter("DRelLearnRate", 0.5, ...
        @(x) validateattributes(x, "numeric", "scalar"));
    parser.addParameter("Lambda", 100, ...
        @(x) validateattributes(x, "numeric", "scalar"));
    parser.addParameter("GDepth", 8, ...
        @(x) validateattributes(x, "numeric", ["scalar","integer","positive"]));
    parser.addParameter("DDepth", 4, ...
        @(x) validateattributes(x, "numeric", ["scalar","integer","positive"]));
    parser.addParameter("Verbose", true, ...
        @(x) validateattributes(x, "logical", "scalar"));
    parser.addParameter("VerboseFrequency", 50, ...
        @(x) validateattributes(x, "numeric", ["scalar","integer","positive"]));
    parser.addParameter("Plots", "training-progress", ...
       @(x) ismember(x, ["none", "training-progress"]));
    
    parser.parse(varargin{:});
    options = parser.Results;
    
    % Convert path the char to ensure isempty checks work.
    options.CheckpointPath = convertStringsToChars(options.CheckpointPath);
end