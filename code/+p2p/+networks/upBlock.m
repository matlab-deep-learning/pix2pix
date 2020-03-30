function out = upBlock(id, nChannels, varargin)
% upBlock    Upsampling block

% Copyright 2020 The MathWorks, Inc.

    out = p2p.networks.block(id, nChannels, 'up', varargin{:});
    out = [out; depthConcatenationLayer(2, 'Name', sprintf('cat_%s', id))];
    
end