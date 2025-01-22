classdef TestFeatureName < matlab.unittest.TestCase
    methods (Test)
        
        function testEnumerationValues(testCase)
            % Test if the enumeration values are correctly assigned
            
            enumValues = enumeration('FeatureName');
            enumValues = cellstr(arrayfun(@char, enumValues, 'UniformOutput', false));
            expectedValues = {'PLAIN'; 'PERTURBED_X0'; 'NOISY'; 'TRUNCATED'; 'PERMUTED'; 'LINEARLY_TRANSFORMED'; 'RANDOM_NAN'; 'UNRELAXABLE_CONSTRAINTS'; 'NONQUANTIFIABLE_CONSTRAINTS'; 'QUANTIZED'; 'CUSTOM'};
            testCase.verifyEqual(enumValues, expectedValues);
        end

        function testConstructor(testCase)
            % Test if the constructor works as expected

            clear obj;
            clear FeatureName;
            testCase.verifyEqual(FeatureName.PLAIN.value, 'plain');
            testCase.verifyEqual(FeatureName.PERTURBED_X0.value, 'perturbed_x0');
            testCase.verifyEqual(FeatureName.NOISY.value, 'noisy');
            testCase.verifyEqual(FeatureName.TRUNCATED.value, 'truncated');
            testCase.verifyEqual(FeatureName.PERMUTED.value, 'permuted');
            testCase.verifyEqual(FeatureName.LINEARLY_TRANSFORMED.value, 'linearly_transformed');
            testCase.verifyEqual(FeatureName.RANDOM_NAN.value, 'random_nan');
            testCase.verifyEqual(FeatureName.UNRELAXABLE_CONSTRAINTS.value, 'unrelaxable_constraints');
            testCase.verifyEqual(FeatureName.NONQUANTIFIABLE_CONSTRAINTS.value, 'nonquantifiable_constraints');
            testCase.verifyEqual(FeatureName.QUANTIZED.value, 'quantized');
            testCase.verifyEqual(FeatureName.CUSTOM.value, 'custom');
        end
        
    end

end