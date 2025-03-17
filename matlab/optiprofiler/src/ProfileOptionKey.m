classdef ProfileOptionKey
%PROFILEOPTIONKEY enumerates options for creating profiles
    
    enumeration
        N_JOBS ('n_jobs')
        KEEP_POOL ('keep_pool')
        SEED ('seed')
        BENCHMARK_ID ('benchmark_id')
        FEATURE_STAMP ('feature_stamp')
        RANGE_TYPE ('range_type')
        SAVEPATH ('savepath')
        MAX_TOL_ORDER ('max_tol_order')
        MAX_EVAL_FACTOR ('max_eval_factor')
        PROJECT_X0 ('project_x0')
        RUN_PLAIN ('run_plain')
        DRAW_PLOTS ('draw_plots')
        SUMMARIZE_PERFORMANCE_PROFILES ('summarize_performance_profiles')
        SUMMARIZE_DATA_PROFILES ('summarize_data_profiles')
        SUMMARIZE_LOG_RATIO_PROFILES ('summarize_log_ratio_profiles')
        SUMMARIZE_OUTPUT_BASED_PROFILES ('summarize_output_based_profiles')
        SILENT ('silent')
        SOLVER_VERBOSE ('solver_verbose')
        SEMILOGX ('semilogx')
        SCORING_FUN ('scoring_fun')
        LOAD ('load')
        LINE_COLORS ('line_colors')
        LINE_STYLES ('line_styles')
        LINE_WIDTHS ('line_widths')
        BAR_COLORS ('bar_colors')
    end
    properties
        value
    end
    methods
        function obj = ProfileOptionKey(inputValue)
            obj.value = inputValue;
        end
    end
end