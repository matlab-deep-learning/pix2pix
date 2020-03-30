classdef instanceNormalizationLayer < nnet.layer.Layer
% instanceNormalizationLayer    Instance Normalization    
    
% Copyright 2020 The MathWorks, Inc.

    properties (Learnable)
        Scale
        Offset
    end
    
    properties
        Epsilon = 1e-5;
    end
    
    methods
        function layer = instanceNormalizationLayer(name)
            layer.Name = name;
            layer.Scale = 1;
            layer.Offset = 0;
        end
        
        function Y = predict(layer, X)
            % Apply instance normalization to X
            
            means = mean(X, [1, 2]);
            variances = var(X, 1, [1, 2]);
            Y = (X - means)./sqrt(variances + layer.Epsilon);
            
            Y = layer.Scale.*Y + layer.Offset;
        end

    end
end