function runAllTests()
    import matlab.unittest.*
    import matlab.unittest.plugins.*
    import matlab.unittest.plugins.codecoverage.*

    try
        artifacts = "artifacts";
        mkdir(artifacts);
        
        junitResults = fullfile(artifacts, "junit");
        mkdir(junitResults);
        
        covResults = fullfile(artifacts, "coverage");
        mkdir(covResults);
        
        % Add folders to path
        install();

        % Assemble test quite
        suite = TestSuite.fromPackage('tests', 'IncludingSubpackages', true);
        runner = TestRunner.withTextOutput;

        % Add tests reults publish plugin
        xmlFile = fullfile(junitResults, "testResults.xml");
        p = XMLPlugin.producingJUnitFormat(xmlFile);
        runner.addPlugin(p)

        % Add code coverage
        covFile = fullfile(covResults, "codeCoverage.xml");
        p = CodeCoveragePlugin.forPackage('p2p',...
            'IncludingSubPackages', true,...
            'Producing', CoberturaFormat(covFile));
        runner.addPlugin(p);

        % run the tests
        runner.run(suite);
       
        % exit with success
        exit(0);
    
    catch err
        % If there is an error then print report and exit
        err.getReport
        exit(1);
    end
end