function model = generator(inputSize, inputChannels, outputChannels, depth)
% generator    pix2pix generator network

% Copyright 2020 The MathWorks, Inc.
    
    downChannels = [64,  128,  256,  512,  512, 512, 512, 512];
    upChannels =  [512, 512, 512, 512, 512, 256, 128, 64];
    
    if nargin < 4
        depth = numel(downChannels);
    else
        assert(depth <= 8, ...
            'p2p:networks:generator', ...
            'Current max depth is 8');
        % Modify down and up channels accordingly
        downChannels = downChannels(1:depth);
        upChannels = upChannels(9-depth:end);
    end
    
    layers = imageInputLayer([inputSize, inputChannels], ...
                            'Name', 'inputImage', ...
                            'Normalization', 'none');
    
    for iLevel = 1:depth
        
        if iLevel == 1
            doNorm = false;
        else
            doNorm = true;
        end
        
        layers = [layers
            p2p.networks.downBlock(sprintf('down_%d', iLevel), downChannels(iLevel), ...
                                    'DoNorm', doNorm)];
    end
    
    for iLevel = depth:-1:1
        if iLevel >= (depth-3)
            doDropout = true;
        else
            doDropout = false;
        end
        
        layers = [layers
            p2p.networks.upBlock(sprintf('up_%d', iLevel), ...
                            upChannels(depth-iLevel+1), ...
                            'Dropout', doDropout)];
    end
    
    layers = [layers
        convolution2dLayer(1, outputChannels, ...
        'Padding', 'same', ...
        'Stride', 1, ...
        'Name', 'Output', ...
        'WeightsInitializer', @(sz) 0.02*randn(sz, 'single'))];
    
    lg = layerGraph(layers);
	% add the skip connections
    for iLevel = 1:depth-1
        lg = lg.connectLayers(sprintf('lrelu_down_%d', iLevel), sprintf('cat_up_%d/in2', iLevel+1));
    end
    lg = lg.connectLayers('inputImage', sprintf('cat_up_%d/in2', 1));
    
    model = dlnetwork(lg);
end
