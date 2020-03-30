classdef WithWorkingDirectory < matlab.unittest.TestCase
% Test fixture for using a working directory with test resources

% Copyright 2020 The MathWorks, Inc.
    
    properties (GetAccess = public, SetAccess = private)
        Root (1,1) string
        Resources (1,1) string
    end
    
    methods (TestMethodSetup)
        function initializeWorkingDirWithResources(this)
            fixture = matlab.unittest.fixtures.WorkingFolderFixture();
            this.applyFixture(fixture);
            this.Root = fixture.Folder;
            this.Resources = fullfile(this.Root, 'resources');
            copyfile(...
                fullfile(testRoot(), 'resources'), ...
                this.Resources ...
               );
        end
        
    end
    
end