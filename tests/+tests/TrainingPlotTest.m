classdef TrainingPlotTest < matlab.unittest.TestCase
% Test of training plots

% Copyright 2020 The MathWorks, Inc.
    properties (TestParameter)
        inChannels = {1, 2, 3, 4}
        outChannels = {1, 1, 3, 1}
    end
    
    methods (Test, ParameterCombination='sequential')
        function testPrepForPlot(test, inChannels, outChannels)
            h = 100;
            w = 200;
            c = inChannels;
            im = dlarray(zeros(h, w, c, "single"), "SSCB");
            
            imOut = p2p.vis.TrainingPlot.prepForPlot(im);
            
            test.assertEqual(size(imOut, [1, 2]), [h, w], ...
                "Height and width should be preserved");
            test.assertEqual(size(imOut, 3), outChannels, ...
                "Channels not as expected");
        end
        
    end
end