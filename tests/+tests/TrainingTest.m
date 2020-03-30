classdef TrainingTest < tests.WithWorkingDirectory
% Full example training test

% Copyright 2020 The MathWorks, Inc.
    
    
    methods (Test)
        function testTrainAndTranslate(test)
            dataFolder = fullfile(toolboxdir('vision'),'visiondata','triangleImages');
            filesA = imageDatastore(fullfile(dataFolder,'trainingLabels')).Files(1:5);
            filesB = imageDatastore(fullfile(dataFolder,'trainingImages')).Files(1:5);
            testImage = imread(filesA{1});
            
            options = p2p.trainingOptions("InputChannels", 1, ...
                                            "OutputChannels", 1, ...
                                            "MaxEpochs", 1, ...
                                            "GDepth", 2, ...
                                            "DDepth", 2, ...
                                            "Plots", "none");
            
            p2pModel = p2p.train(filesA, filesB, options);
            
            translatedImage = p2p.translate(p2pModel, testImage);
            
            test.verifyEqual(size(translatedImage), size(testImage));
        end
        
        function testTrainAndResume(test)
            dataFolder = fullfile(toolboxdir('vision'),'visiondata','triangleImages');
            filesA = imageDatastore(fullfile(dataFolder,'trainingLabels')).Files(1:5);
            filesB = imageDatastore(fullfile(dataFolder,'trainingImages')).Files(1:5);
            testImage = imread(filesA{1});
            
            options = p2p.trainingOptions("InputChannels", 1, ...
                                            "OutputChannels", 1, ...
                                            "MaxEpochs", 1, ...
                                            "GDepth", 2, ...
                                            "DDepth", 2, ...
                                            "CheckpointPath", "temp", ...
                                            "Plots", "none");
            
            p2p.train(filesA, filesB, options);
            
            checkpointFile = dir("temp/**/*.mat");
            test.verifyEqual(numel(checkpointFile), 1, ...
                "One checkpoint should be saved");
            checkpointFilepath = fullfile(checkpointFile.folder, checkpointFile.name);
            options.ResumeFrom = checkpointFilepath;
            
            % Already done 1 epoch, so this shouldn't do any more
            p2p.train(filesA, filesB, options);
            checkpointFile = dir("temp/**/*.mat");
            test.verifyEqual(numel(checkpointFile), 1, ...
                "Shouldn't do any more epochs");
            
            options.MaxEpochs = 2;
            p2pModel = p2p.train(filesA, filesB, options);
            checkpointFile = dir("temp/**/*.mat");
            test.verifyEqual(numel(checkpointFile), 2, ...
                "Should have 2 checkpoint");
            
            translatedImage = p2p.translate(p2pModel, testImage);
            test.verifyEqual(size(translatedImage), size(testImage));
        end
        
        function testWithPlot(test)
            dataFolder = fullfile(toolboxdir('vision'),'visiondata','triangleImages');
            filesA = imageDatastore(fullfile(dataFolder,'trainingLabels')).Files(1:5);
            filesB = imageDatastore(fullfile(dataFolder,'trainingImages')).Files(1:5);
            
            options = p2p.trainingOptions("InputChannels", 1, ...
                                            "OutputChannels", 1, ...
                                            "MaxEpochs", 2, ...
                                            "GDepth", 2, ...
                                            "DDepth", 2, ...
                                            "Plots", "training-progress");
            
            p2p.train(filesA, filesB, options);
            
            % Just check that the training figure was created
            f = findobj(groot, "Tag", "p2p.vis.TrainingPlot");
            test.verifyEqual(numel(f), 1, ...
                "1 training plot should be created");
            close(f);
        end
    end
    
end