classdef AdamOptimiser < handle
% AdamOptimiser A convenience class for handling Adam state.
%
%   This class takes care of keeping track of the running statistics of
%   average gradient and average squared gradient. It also automatically
%   increments the current iteration on every call to update.
%
% Note:
%   The parameter update does NOT use weight decay.

% Copyright 2020 The MathWorks, Inc.

    properties
        LearnRate
        Beta1
        Beta2
        Iteration = 1
        AvgGradient
        AvgGradientSq
    end
    
    methods
        function obj = AdamOptimiser(lr, beta1, beta2)
            obj.LearnRate = lr;
            obj.Beta1 = beta1;
            obj.Beta2 = beta2;
        end
        
        function updatedParams = update(obj, params, gradients)
            % Apply the Adam update to parameters given a set of gradients
            
            if ~isempty(obj.AvgGradient)
                assert(height(params) == height(obj.AvgGradient), ...
                    "p2p:util:AdamOptimiser", ...
                    "Size of parameters should not change during optimisation.");
            end
            
            [updatedParams, obj.AvgGradient, obj.AvgGradientSq] = ...
                adamupdate(params, gradients, ...
                    obj.AvgGradient, obj.AvgGradientSq, ...
                    obj.Iteration, obj.LearnRate, obj.Beta1, obj.Beta2);
            obj.Iteration = obj.Iteration + 1;
        end
    end
end