classdef TrainingPlot < handle
% TrainingPlot    Displays training progress

% Copyright 2020 The MathWorks, Inc.
    
    properties (Access = private)
        TiledChart
        InputsAx
        OutputsAx
        LossAx1
        LossAx2
        InputsIm
        OutputsIm
        ExampleInputs
        Lines = matlab.graphics.animation.AnimatedLine.empty
        StartTime
    end
    
    methods
        function obj = TrainingPlot(exampleInputs)
            
            obj.StartTime = datetime("now");
            
            trainingName = sprintf("pix2pix training started at %s", ...
                                obj.StartTime);
            fig = figure("Units", "Normalized", ...
                            "Position", [0.1, 0.1, 0.7, 0.6], ...
                            "Name", trainingName, ...
                            "NumberTitle", "off", ...
                            "Tag", "p2p.vis.TrainingPlot");
            obj.TiledChart = tiledlayout(fig, 3, 4, ...
                                        "TileSpacing", "compact", ...
                                        "Padding", "compact");
            obj.InputsAx = nexttile(obj.TiledChart, 1, [2, 2]);
            obj.OutputsAx = nexttile(obj.TiledChart, 3, [2, 2]);
            obj.LossAx1 = nexttile(obj.TiledChart, 9, [1, 2]);
            obj.LossAx2 = nexttile(obj.TiledChart, 11, [1, 2]);
            
            obj.ExampleInputs = exampleInputs;
            obj.initImages();
            obj.initLines();
            drawnow();
        end
        
        function update(obj, epoch, iteration,  ...
                    gLoss, lossL1, ganLoss, dLoss, generator)
            obj.updateImages(generator)
            obj.updateLines(epoch, iteration, gLoss, lossL1, ganLoss, dLoss);
            drawnow();
        end
        
        function initImages(obj)
            displayIm = obj.prepForPlot(obj.ExampleInputs);
            montageIm = imtile(displayIm);
            obj.InputsIm = imshow(montageIm, "Parent", obj.InputsAx);
            
            zeroIm = 0*montageIm;
            obj.OutputsIm = imshow(zeroIm, "Parent", obj.OutputsAx);
        end
        
        function updateImages(obj, generator)
            output = tanh(generator.forward(obj.ExampleInputs));
            displayIm = obj.PrepForPlot(output);
            obj.OutputsIm.CData = imtile(displayIm);
        end
        
        function initLines(obj)
            % First plot just for generator
            obj.Lines(1) = animatedline(obj.LossAx1, ...
                                        "LineWidth", 1, ...
                                        "DisplayName", "Generator total");
            xlabel(obj.LossAx1, "Iteration");
            ylabel(obj.LossAx1, "Loss");
            grid(obj.LossAx1, "on");
            legend(obj.LossAx1);
            
            % Remaining plots for other losses
            nLines = 3;
            cMap = parula(nLines);
            labels = ["L1 loss", "GAN loss", "Discriminator loss"];
            for iLine = 1:nLines
                obj.Lines(iLine + 1) = animatedline(obj.LossAx2, ...
                                                "Color", cMap(iLine, :), ...
                                                "LineWidth", 1, ...
                                                "DisplayName", labels(iLine));
            end
            xlabel(obj.LossAx2, "Iteration");
            ylabel(obj.LossAx2, "Loss");
            grid(obj.LossAx2, "on");
            legend(obj.LossAx2);
        end
        
        function updateLines(obj, epoch, iteration, gLoss, lossL1, ganLoss, dLoss)
            titleString = sprintf("Current epoch: %d, elapsed time: %s", ...
                                    epoch, datetime("now") - obj.StartTime);
            title(obj.LossAx1, titleString);
            addpoints(obj.Lines(1), iteration, double(gLoss));
            addpoints(obj.Lines(2), iteration, double(lossL1));
            addpoints(obj.Lines(3), iteration, double(ganLoss));
            addpoints(obj.Lines(4), iteration, double(dLoss));
        end
        
    end
    
    methods (Static)
        function imOut = prepForPlot(im)
            nChannels = size(im, 3);
            imOut = (gather(extractdata(im)) + 1)/2;
            
            % only take the first channel for n != 3
            if nChannels ~= 3
                imOut = imOut(:,:,1,:);
            end
        end
    end
end