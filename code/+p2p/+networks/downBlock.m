function out = downBlock(id, nChannels, varargin)
% downBlock    Downsampling block

% Copyright 2020 The MathWorks, Inc.

    out = p2p.networks.block(id, nChannels, 'down', varargin{:});
    
end
