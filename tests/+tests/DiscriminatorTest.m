classdef DiscriminatorTest < matlab.unittest.TestCase
% Tests for the discriminator

% Copyright 2020 The MathWorks, Inc.
    
    properties (TestParameter)
        miniBatchSize = {1, 2, 3}
    end
    
    
    methods (Test)
        function testForwardOutputSize(testCase, miniBatchSize)
            inputSize = [256, 256];
            inputChannels = 3;
            inputData = dlarray(zeros([inputSize, inputChannels, miniBatchSize], 'single'), 'SSCB');
            expectedSize = [16, 16, 1, miniBatchSize];
            
            d = p2p.networks.discriminator(inputSize, inputChannels);
            output = extractdata(d.forward(inputData));
            
            testCase.verifyEqual(size(output(:,:,1,1)), expectedSize(1:2));
            testCase.verifyEqual(size(output, 3), expectedSize(3));
            % Verify batch dimension separately in case it is 1
            testCase.verifyEqual(size(output, 4), expectedSize(4));
        end
    end
end