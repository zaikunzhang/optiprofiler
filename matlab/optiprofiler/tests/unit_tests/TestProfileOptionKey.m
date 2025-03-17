classdef TestProfileOptionKey < matlab.unittest.TestCase
    methods (Test)
        
        function testEnumerationValues(testCase)
            % Test if the enumeration values are correctly assigned
            
            enumValues = enumeration('ProfileOptionKey');
            enumValues = cellstr(arrayfun(@char, enumValues, 'UniformOutput', false));
            expectedValues = {'N_JOBS'; 'KEEP_POOL'; 'SEED'; 'BENCHMARK_ID'; 'FEATURE_STAMP'; 'RANGE_TYPE'; 'SAVEPATH'; 'MAX_TOL_ORDER'; 'MAX_EVAL_FACTOR'; 'PROJECT_X0'; 'RUN_PLAIN'; 'DRAW_PLOTS'; 'SUMMARIZE_PERFORMANCE_PROFILES'; 'SUMMARIZE_DATA_PROFILES'; 'SUMMARIZE_LOG_RATIO_PROFILES'; 'SUMMARIZE_OUTPUT_BASED_PROFILES'; 'SILENT'; 'SOLVER_VERBOSE'; 'SEMILOGX'; 'SCORING_FUN'; 'LOAD'; 'LINE_COLORS'; 'LINE_STYLES'; 'LINE_WIDTHS'; 'BAR_COLORS'};
            testCase.verifyEqual(enumValues, expectedValues);
        end

        function testConstructor(testCase)
            % Test if the constructor works as expected

            clear obj;
            clear ProfileOptionKey;
            testCase.verifyEqual(ProfileOptionKey.N_JOBS.value, 'n_jobs');
            testCase.verifyEqual(ProfileOptionKey.KEEP_POOL.value, 'keep_pool');
            testCase.verifyEqual(ProfileOptionKey.SEED.value, 'seed');
            testCase.verifyEqual(ProfileOptionKey.BENCHMARK_ID.value, 'benchmark_id');
            testCase.verifyEqual(ProfileOptionKey.RANGE_TYPE.value, 'range_type');
            testCase.verifyEqual(ProfileOptionKey.SAVEPATH.value, 'savepath');
            testCase.verifyEqual(ProfileOptionKey.MAX_TOL_ORDER.value, 'max_tol_order');
            testCase.verifyEqual(ProfileOptionKey.MAX_EVAL_FACTOR.value, 'max_eval_factor');
            testCase.verifyEqual(ProfileOptionKey.PROJECT_X0.value, 'project_x0');
            testCase.verifyEqual(ProfileOptionKey.RUN_PLAIN.value, 'run_plain');
            testCase.verifyEqual(ProfileOptionKey.DRAW_PLOTS.value, 'draw_plots');
            testCase.verifyEqual(ProfileOptionKey.SUMMARIZE_PERFORMANCE_PROFILES.value, 'summarize_performance_profiles');
            testCase.verifyEqual(ProfileOptionKey.SUMMARIZE_DATA_PROFILES.value, 'summarize_data_profiles');
            testCase.verifyEqual(ProfileOptionKey.SUMMARIZE_LOG_RATIO_PROFILES.value, 'summarize_log_ratio_profiles');
            testCase.verifyEqual(ProfileOptionKey.SUMMARIZE_OUTPUT_BASED_PROFILES.value, 'summarize_output_based_profiles');
            testCase.verifyEqual(ProfileOptionKey.SILENT.value, 'silent');
            testCase.verifyEqual(ProfileOptionKey.SOLVER_VERBOSE.value, 'solver_verbose');
            testCase.verifyEqual(ProfileOptionKey.SEMILOGX.value, 'semilogx');
            testCase.verifyEqual(ProfileOptionKey.SCORING_FUN.value, 'scoring_fun');
            testCase.verifyEqual(ProfileOptionKey.LOAD.value, 'load');
            testCase.verifyEqual(ProfileOptionKey.LINE_COLORS.value, 'line_colors');
            testCase.verifyEqual(ProfileOptionKey.LINE_STYLES.value, 'line_styles');
            testCase.verifyEqual(ProfileOptionKey.LINE_WIDTHS.value, 'line_widths');
            testCase.verifyEqual(ProfileOptionKey.BAR_COLORS.value, 'bar_colors');
        end
        
    end

end