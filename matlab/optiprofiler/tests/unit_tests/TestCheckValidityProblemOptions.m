classdef TestCheckValidityProblemOptions < matlab.unittest.TestCase
    methods (Test)

        function testErrors(testCase)

            options = struct();

            options.plibs = 1;
            testCase.verifyError(@() checkValidityProblemOptions(options), "MATLAB:checkValidityProblemOptions:plibsNotValid");
            if ~isunix || ismac
                options.plibs = {'matcutest'};
                testCase.verifyError(@() checkValidityProblemOptions(options), "MATLAB:checkValidityProblemOptions:plibsNotLinux");
            end
            options = rmfield(options, 'plibs');


            options.ptype = 1;
            testCase.verifyError(@() checkValidityProblemOptions(options), "MATLAB:checkValidityProblemOptions:ptypeNotcharstr");
            options.ptype = 'a';
            testCase.verifyError(@() checkValidityProblemOptions(options), "MATLAB:checkValidityProblemOptions:ptypeNotubln");
            options = rmfield(options, 'ptype');


            options.mindim = 0;
            testCase.verifyError(@() checkValidityProblemOptions(options), "MATLAB:checkValidityProblemOptions:mindimNotValid");
            options = rmfield(options, 'mindim');
            options.maxdim = 0;
            testCase.verifyError(@() checkValidityProblemOptions(options), "MATLAB:checkValidityProblemOptions:maxdimNotValid");
            options.mindim = 2;
            options.maxdim = 1;
            testCase.verifyError(@() checkValidityProblemOptions(options), "MATLAB:checkValidityProblemOptions:maxdimSmallerThanmindim");
            options = rmfield(options, 'mindim');
            options = rmfield(options, 'maxdim');


            options.minb = -1;
            testCase.verifyError(@() checkValidityProblemOptions(options), "MATLAB:checkValidityProblemOptions:minbNotValid");
            options.minb = 2;
            options.maxb = -1;
            testCase.verifyError(@() checkValidityProblemOptions(options), "MATLAB:checkValidityProblemOptions:maxbNotValid");
            options.maxb = 1;
            testCase.verifyError(@() checkValidityProblemOptions(options), "MATLAB:checkValidityProblemOptions:maxbSmallerThanminb");
            options = rmfield(options, 'minb');
            options = rmfield(options, 'maxb');


            options.mincon = -1;
            testCase.verifyError(@() checkValidityProblemOptions(options), "MATLAB:checkValidityProblemOptions:minconNotValid");
            options.mincon = 2;
            options.maxcon = -1;
            testCase.verifyError(@() checkValidityProblemOptions(options), "MATLAB:checkValidityProblemOptions:maxconNotValid");
            options.maxcon = 1;
            testCase.verifyError(@() checkValidityProblemOptions(options), "MATLAB:checkValidityProblemOptions:maxconSmallerThanmincon");
            options = rmfield(options, 'mincon');
            options = rmfield(options, 'maxcon');


            options.excludelist = 1;
            testCase.verifyError(@() checkValidityProblemOptions(options), "MATLAB:checkValidityProblemOptions:excludelistNotCellOfcharstr");
            options = rmfield(options, 'excludelist');


            options.problem_names = 1;
            testCase.verifyError(@() checkValidityProblemOptions(options), "MATLAB:checkValidityProblemOptions:problem_namesNotCellOfcharstr");
        end

    end

end