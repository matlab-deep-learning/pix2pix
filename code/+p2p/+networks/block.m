function layers = block(id, nChannels, direction, varargin)
% block    Base building block of networks

% Copyright 2020 The MathWorks, Inc.

    parser = inputParser();
    parser.addRequired('nChannels');
    parser.addRequired('direction');
    parser.addParameter('NormType', 'batch');
    parser.addParameter('DoNorm', true);
    parser.addParameter('Dropout', false);
    parser.addParameter('KernelSize', 4);
    parser.parse(nChannels, direction, varargin{:});
    inputs = parser.Results;
    
    switch inputs.direction 
        case 'down'
            conv = @convolution2dLayer;
            padName = 'Padding';
        case 'up'
            conv = @transposedConv2dLayer;
            padName = 'Cropping';
        otherwise
            error('Unrecognised parameter');
    end
    
    layers = conv(inputs.KernelSize, inputs.nChannels, ...
                'Name', sprintf('conv_%s', id), ...
                padName, 'same', ...
                'Stride', 2, ...
                'WeightsInitializer', @(sz) 0.02*randn(sz, 'single'));
    
    if inputs.DoNorm
        switch inputs.NormType
            case 'instance'
                layers = [layers; p2p.networks.instanceNormalizationLayer(sprintf('in_%s', id))];
            case 'batch'
                layers = [layers; batchNormalizationLayer('Name', sprintf('bn_%s', id))];
            case 'none'
                % no normalization
            otherwise
                error('p2p:networks:badNorm', 'unrecognised normalisation type ''%s''.', inputs.NormType)
        end
    end
    if inputs.Dropout
        layers = [layers; dropoutLayer(0.5, 'Name', sprintf('drop_%s', id))];
    end
    layers = [layers; leakyReluLayer(0.2, 'Name', sprintf('lrelu_%s', id))];
end