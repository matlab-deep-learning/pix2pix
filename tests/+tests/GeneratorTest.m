classdef GeneratorTest < matlab.unittest.TestCase
% Tests for the generator

% Copyright 2020 The MathWorks, Inc.

    properties (TestParameter)
        miniBatchSize = {1, 2, 3}
        inputChannels = {1, 3}
    end
    
    
    methods (Test)
        function testForwardOutputSize(testCase, inputChannels, miniBatchSize)
            inputSize = [256, 256];
            outputChannels = 3;
            inputData = dlarray(zeros([inputSize, inputChannels, miniBatchSize], 'single'), 'SSCB');
            expectedSize = [256, 256, outputChannels, miniBatchSize];
            
            g = p2p.networks.generator(inputSize, inputChannels, outputChannels);
            output = extractdata(g.forward(inputData));
            
            testCase.verifyEqual(size(output(:,:,:,1)), expectedSize(1:3));
            % Verify batch dimension separately in case it is 1
            testCase.verifyEqual(size(output, 4), expectedSize(4));
        end
        
    end
end