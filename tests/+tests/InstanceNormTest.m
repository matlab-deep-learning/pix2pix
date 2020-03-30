classdef InstanceNormTest < matlab.unittest.TestCase
% Test instance normlization layer

% Copyright 2020 The MathWorks, Inc.
    
    methods (Test)
        function testCreate(testCase)
            name = 'InstanceNorm1';
            expectedScale = 1;
            expectedOffset = 0;
            layer = p2p.networks.instanceNormalizationLayer(name);
            
            testCase.verifyEqual(layer.Name, name);
            testCase.verifyEqual(layer.Scale, expectedScale);
            testCase.verifyEqual(layer.Offset, expectedOffset);
        end
        
        function testForward(testCase)
            layer = p2p.networks.instanceNormalizationLayer('test');
            X = ones(10, 11, 3, 5);
            Y = layer.predict(X);
            
            testCase.verifyEqual(size(Y), size(X));
            testCase.verifyTrue(all(Y == 0, 'all'));
        end
        
        function testForwardChannels(testCase)
            % test normalisation along channels
            layer = p2p.networks.instanceNormalizationLayer('test');
            X = cat(3, 1*ones(10, 11, 1, 5), ...
                        2*ones(10, 11, 1, 5), ...
                        3*ones(10, 11, 1, 5));
            Y = layer.predict(X);
            
            testCase.verifyEqual(size(Y), size(X));
            testCase.verifyTrue(all(Y == 0, 'all'));
        end
        
        function testBatchNormEquivDlarray(testCase)
            % behaviour should be the same as batch norm for batchsize = 1
            nChannels = 9;
            X = dlarray(rand(13, 15, nChannels, 1), 'SSCB');
            expected = batchnorm(X, zeros(nChannels, 1), ones(nChannels,1));
            
            layer = p2p.networks.instanceNormalizationLayer('test');
            Y = layer.predict(X);
            
            testCase.verifyEqual(extractdata(Y), extractdata(expected), ...
                                    'RelTol', 1e-5)
        end
        
        function testForwardChannelsBatch(testCase)
            % test normalisation along channels and batch dim
            layer = p2p.networks.instanceNormalizationLayer('test');
            oneX = cat(3, 1*ones(10, 11, 1, 1), ...
                        2*ones(10, 11, 1, 1), ...
                        3*ones(10, 11, 1, 1));
            X = cat(4, oneX, 2*oneX, 3*oneX);
            Y = layer.predict(X);
            
            testCase.verifyEqual(size(Y), size(X));
            testCase.verifyTrue(all(Y == 0, 'all'));
        end
        
        function testForwardOffset(testCase)
            layer = p2p.networks.instanceNormalizationLayer('test');
            offset = 100;
            layer.Offset = offset;
            X = ones(10, 11, 3, 5);
            Y = layer.predict(X);
            
            testCase.verifyEqual(size(Y), size(X));
            testCase.verifyTrue(all(Y == offset, 'all'));
        end
        
        function testLayerChecks(testCase)
            results = checkLayer(p2p.networks.instanceNormalizationLayer('test'), [10, 22, 4, 12]);
            testCase.verifyTrue(all([results.Passed]));
        end
    end
    
end