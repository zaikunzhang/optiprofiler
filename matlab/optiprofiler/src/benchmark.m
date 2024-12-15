function benchmark(solvers, varargin)
%BENCHMARK Create multiple profiles for benchmarking optimization solvers on a
%   set of problems with different features.
%
%   Signitures:
%
%   BENCHMARK(SOLVERS) creates performance profiles and data profiles for the
%   given SOLVERS with default unconstrained problem set and feature plain.
%   SOLVERS is a cell array of function handles whom we require to accept
%   specified inputs and return specified outputs. Details can be found in the
%   'Cautions' part.
%
%   BENCHMARK(SOLVERS, FEATURE_NAME) creates performance profiles and data
%   profiles for the given SOLVERS with default unconstrained problem set and
%   the specified feature FEATURE_NAME.
%
%   BENCHMARK(SOLVERS, OPTIONS) creates performance profiles and data profiles
%   for the given SOLVERS with options specified in the struct OPTIONS.
%   OPTIONS can contain the following fields:
%       1. options for profiles and plots:
%       - n_jobs: the number of parallel jobs to run the test. Default is 1.
%       - benchmark_id: the identifier of the test. It is used to create the
%         specific directory to store the results. Default is '.' .
%       - range_type: the type of the uncertainty interval. For stochastic
%         features, we run several times of the experiments and get average
%         curves and uncertainty intervals. Default is 'minmax', meaning that
%         we takes the pointwise minimum and maximum of the curves.
%       - savepath: the path to store the results. Default is the current
%         directory where the function is called.
%       - max_tol_order: the maximum order of the tolerance. In any profile
%         (performance profiles, data profiles, and log-ratio profiles), we
%         need to set a group of 'tolerances' to define the 'convergence' of
%         the solvers. (Details can be found in the references.) We will set
%         the tolerances as 10^(-1:-1:-max_tol_order). Default is 10.
%       - max_eval_factor: the factor multiplied to each problem's dimension to
%         get the maximum number of evaluations for each problem. Default is
%         500.
%       - project_x0: whether to project the initial point to the feasible set.
%         Default is false.
%       - run_plain: whether to run an extra experiment with the 'plain'
%         feature. Default is false.
%       - summarize_performance_profiles: whether to add all the performance
%         profiles to the summary PDF. Default is true.
%       - summarize_data_profiles: whether to add all the data profiles to the
%         summary PDF. Default is true.
%       - summarize_log_ratio_profiles: whether to add all the log-ratio
%         profiles to the summary PDF. Default is false.
%       - summarize_output_based_profiles: whether to add all the output-based
%         profiles of the selected profiles to the summary PDF. Default is
%         true.
%       2. options for features:
%       - feature_name: the name of the feature. Default is 'plain'.
%       - n_runs: the number of runs of the experiments under the given
%         feature. Default is 10 for stochastic features and 1 for
%         deterministic features.
%       - distribution: the distribution of perturbation in 'perturbed_x0'
%         feature or noise in 'noisy' feature. It should be either a string
%         (or char), or a function handle
%               (random stream, dimension) -> random vector,
%         accepting a random stream and the dimension of a problem and
%         returning a random vector with the given dimension. In 'perturbed_x0'
%         case, the char should be either 'spherical' or 'gaussian' (default is
%         'spherical'). In 'noisy' case, the char should be either 'gaussian'
%         or 'uniform' (default is 'gaussian').
%       - noise_level: the magnitude of the noise in stochastic features.
%         Default is 10^-3.
%       - noise_type: the type of the noise in stochastic features. It should
%         be either 'absolute' or 'relative'. Default is 'relative'.
%       - significant_digits: the number of significant digits in the
%         'truncated' feature. Default is 6.
%       - perturbed_trailing_zeros: whether we will set the trailing zeros of
%         the objective function value to be random in the 'perturbed_x0'
%         feature. Default is false.
%       - rotated: whether to use a random or given rotation matrix to rotate
%         the coordinates of a problem in the 'linearly_transformed' feature.
%         Default is true.
%       - condition_factor: the scaling factor of the condition number of the
%         linear transformation in the 'linearly_transformed' feature. More
%         specifically, the condition number of the linear transformation will
%         2 ^ (condition_factor * n / 2), where `n` is the dimension of the
%         problem. Default is 0.
%       - nan_rate: the probability that the evaluation of the objective
%         function will return NaN in the 'random_nan' feature. Default is
%         0.05.
%       - unrelaxable_bounds: whether the bound constraints are unrelaxable or
%         not in the 'unrelaxable_constraints' feature. Default is false.
%       - unrelaxable_linear_constraints: whether the linear constraints are
%         unrelaxable or not in the 'unrelaxable_constraints' feature. Default
%         is false.
%       - unrelaxable_nonlinear_constraints: whether the nonlinear constraints
%         are unrelaxable or not in the 'unrelaxable_constraints' feature.
%         Default is false.
%       - mesh_size: the size of the mesh in the 'quantized' feature. Default
%         is 10^-3.
%       - ground_truth: whether the feature is the ground truth or not. Default is
%         true.
%       - mod_x0: the modifier function to modify the inital guess in the 
%         'custom' feature. It should be a function handle as follows:
%               (random_stream, problem) -> modified_x0,
%         where `problem` is an instance of the class Problem, and modified_x0 is
%         the modified initial guess. No default.
%       - mod_affine: the modifier function to generate the affine
%         transformation applied to the variables in the 'custom' feature. It
%         should be a function handle as follows:
%               (random_stream, problem) -> (A, b, inv),
%         where `problem` is an instance of the class Problem, A is the matrix of
%         the affine transformation, b is the vector of the affine
%         transformation, and inv is the inverse of the matrix A. No default.
%       - mod_bounds: the modifier function to modify the bound constraints in
%         the 'custom' feature. It should be a function handle as follows:
%               (random_stream, problem) -> (modified_xl, modified_xu),
%         where `problem` is an instance of the class Problem, modified_xl is the
%         modified lower bound, and modified_xu is the modified upper bound. No
%         default.
%       - mod_linear_ub: the modifier function to modify the linear inequality
%         constraints in the 'custom' feature. It should be a function handle
%         as follows:
%               (random_stream, problem) -> (modified_aub, modified_bub),
%         where `problem` is an instance of the class Problem, modified_aub is
%         the modified matrix of the linear inequality constraints, and
%         modified_bub is the modified vector of the linear inequality
%         constraints. No default.
%       - mod_linear_eq: the modifier function to modify the linear equality
%         constraints in the 'custom' feature. It should be a function handle
%         as follows:
%               (random_stream, problem) -> (modified_aeq, modified_beq),
%         where `problem` is an instance of the class Problem, modified_aeq is
%         the modified matrix of the linear equality constraints, and
%         modified_beq is the modified vector of the linear equality
%         constraints. No default.
%       - mod_fun: the modifier function to modify the objective function in
%         the 'custom' feature. It should be a function handle as follows:
%               (x, random_stream, problem) -> modified_fun,
%         where `x` is the evaluation point, problem is an instance of the class
%         Problem, and modified_fun is the modified objective function value.
%         No default.
%       - mod_cub: the modifier function to modify the nonlinear inequality
%         constraints in the 'custom' feature. It should be a function handle
%         as follows:
%               (x, random_stream, problem) -> modified_cub,
%         where x is the evaluation point, problem is an instance of the class
%         Problem, and modified_cub is the modified vector of the nonlinear
%         inequality constraints. No default.
%       - mod_ceq: the modifier function to modify the nonlinear equality
%         constraints in the 'custom' feature. It should be a function handle
%         as follows:
%               (x, random_stream, problem) -> modified_ceq,
%         where x is the evaluation point, problem is an instance of the class
%         Problem, and modified_ceq is the modified vector of the nonlinear
%         equality constraints. No default.
%       3. options for CUTEst:
%       Note that the CUTEst we used is the MATLAB codes from a GitHub
%       repository called 'S2MPJ', created by Professor Serge Gratton and
%       Professor Philippe L. Toint. More details can be found in the following
%       website.
%           https://github.com/GrattonToint/S2MPJ
%       - problem: a instance of the class Problem. If it is provided, we will
%         only solve this problem and generate the history plots for it.
%         Default is not to provide any problem.
%       - p_type: the type of the problems to be selected. It should be a
%         string containing the combination of 'u' (unconstrained), 'b' (bound
%         constrained), 'l' (linearly constrained), and 'n' (nonlinearly
%         constrained). Default is 'u'.
%       - mindim: the minimum dimension of the problems to be selected. Default
%         is 1.
%       - maxdim: the maximum dimension of the problems to be selected. Default
%         is 5.
%       - mincon: the minimum number of constraints of the problems to be
%         selected. Default is 0.
%       - maxcon: the maximum number of constraints of the problems to be
%         selected. Default is 10 for linearly or nonlinearly constrained
%         problems, and 0 for the others.
%       - excludelist: the list of problems to be excluded. Default is not to
%         exclude any problem.
%       4. other options:
%       - solver_names: the names of the solvers. Default is the function names
%         of the solvers.
%       - solver_isrand: whether the solvers are randomized or not. Default is
%         a vector of false.
%       - feature_stamp: the stamp of the feature with the given options. It is
%         used to create the specific directory to store the results. Default
%         is different for different features.
%       - cutest_problem_names: the names of the problems in the CUTEst library
%         to be selected. Default is not to select any problem from the CUTEst
%         library by name but by the options above.
%       - custom_problem_loader: the function handle to load the custom
%         problems. It should be a function handle as follows:
%               (problem_name) -> problem,
%         where problem_name is the name of the problem, and problem is an
%         instance of the class Problem. Default is not to load any custom
%         problem.
%       - custom_problem_names: the names of the custom problems to be
%         selected. Default is not to select any custom problem.
%
%   Cautions:
%
%   1. Each solver in SOLVERS should accept the following signature:
%       - if you want to solve an unconstrained problem,
%           x = solver(fun, x0),
%         where fun is a function handle of the objective function accepting a
%         column vector and returning a real number, and x0 is the initial
%         guess which is a column vector;
%       - if you want to solve a bound-constrained problem,
%           x = solver(fun, x0, xl, xu),
%         where xl and xu are the lower and upper bounds of the variables which
%         are column vectors (they can contain Inf or -Inf);
%       - if you want to solve a linearly constrained problem,
%           x = solver(fun, x0, xl, xu, aub, bub, aeq, beq);
%         where aub and 
%
%   For more information of performance and data profiles, see [1]_, [2]_,
%   [4]_. For that of log-ratio profiles, see [3]_, [5]_. Pay attention that 
%   log-ratio profiles are available only when there are exactly two solvers.
%
%   References:
%   .. [1] E. D. Dolan and J. J. Moré. Benchmarking optimization software with
%          performance profiles. *Math. Program.*, 91(2):201–213, 2002.
%          `doi:10.1007/s101070100263
%          <https://doi.org/10.1007/s101070100263>.
%   .. [2] N. Gould and J. Scott. A note on performance profiles for
%          benchmarking software. *ACM Trans. Math. Software*, 43(2):15:1–5,
%          2016. `doi:10.1145/2950048 <https://doi.org/10.1145/2950048>.
%   .. [3] J. L. Morales. A numerical study of limited memory BFGS methods.
%          *Appl. Math. Lett.*, 15(4):481–487, 2002.
%          `doi:10.1016/S0893-9659(01)00162-8
%          <https://doi.org/10.1016/S0893-9659(01)00162-8>.
%   .. [4] J. J. Moré and S. M. Wild. Benchmarking derivative-free optimization
%          algorithms. *SIAM J. Optim.*, 20(1):172–191, 2009.
%          `doi:10.1137/080724083 <https://doi.org/10.1137/080724083>.
%   .. [5] H.-J. M. Shi, M. Q. Xuan, F. Oztoprak, and J. Nocedal. On the
%          numerical performance of finite-difference-based methods for
%          derivative-free optimization. *Optim. Methods Softw.*,
%          38(2):289–311, 2023. `doi:10.1080/10556788.2022.2121832
%          <https://doi.org/10.1080/10556788.2022.2121832>.
%
%   **************************************************************************
%   Authors:    Cunxin HUANG (cun-xin.huang@connect.polyu.hk)
%               Tom M. RAGONNEAU (t.ragonneau@gmail.com)
%               Zaikun ZHANG (zaikun.zhang@polyu.edu.hk)
%               Department of Applied Mathematics,
%               The Hong Kong Polytechnic University
%   **************************************************************************

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Preprocess the input arguments. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Initialize options_store to store the options for later reproduction.
    options_store = struct();

    if nargin == 0
        error("MATLAB:benchmark:solverMustBeProvided", "A cell of function handles (callable solvers) must be provided as the first argument.");
    elseif nargin == 1
        % When input only contains one argument, we assume the user chooses benchmark(solvers) and
        % test plain feature.
        feature_name = 'plain';
        options_store.feature_name = feature_name;
        cutest_problem_names = {};
        custom_problem_loader = {};
        custom_problem_names = {};
        options = struct();
    elseif nargin == 2
        if ischarstr(varargin{1}) || (iscell(varargin{1}) && all(cellfun(@ischarstr, varargin{1})))
            % When input contains two arguments and the second argument is a char or cell of char,
            % we assume the user chooses benchmark(solvers, feature_name).
            feature_name = varargin{1};
            options_store.feature_name = feature_name;
            cutest_problem_names = {};
            custom_problem_loader = {};
            custom_problem_names = {};
            options = struct();
        elseif isstruct(varargin{1})
            % When input contains two arguments and the second argument is a struct, we assume the
            % user chooses benchmark(solvers, options).
            options = varargin{1};
            if isfield(options, 'feature_name')
                feature_name = options.feature_name;
                options = rmfield(options, 'feature_name');
            else
                feature_name = 'plain';
            end
            options_store.feature_name = feature_name;

            if isfield(options, 'solver_names')
                solver_names = options.solver_names;
                options = rmfield(options, 'solver_names');
                options_store.solver_names = solver_names;
            end

            if isfield(options, 'feature_stamp')
                feature_stamp = options.feature_stamp;
                options = rmfield(options, 'feature_stamp');
                options_store.feature_stamp = feature_stamp;
            end

            if isfield(options, 'problem') && ~isempty(options.problem)
                if ~isa(options.problem, 'Problem')
                    error("MATLAB:benchmark:problemNotProblem", "The field `problem` of `options` for `benchmark` must be a Problem object.");
                end
                cutest_problem_names = {};
                custom_problem_loader = @(x) options.problem;
                custom_problem_names = {options.problem.name};
                options_store.problem = options.problem;
                options = rmfield(options, 'problem');
            else
                if isfield(options, 'cutest_problem_names')
                    cutest_problem_names = options.cutest_problem_names;
                    options_store.cutest_problem_names = cutest_problem_names;
                    options = rmfield(options, 'cutest_problem_names');
                else
                    cutest_problem_names = {};
                end
                if isfield(options, 'custom_problem_loader') && isfield(options, 'custom_problem_names')
                    if isempty(options.custom_problem_names)
                        error("MATLAB:benchmark:customnamesEmpty", "`custom_problem_names` cannot be empty if provided.");
                    end
                    custom_problem_loader = options.custom_problem_loader;
                    custom_problem_names = options.custom_problem_names;
                    options_store.custom_problem_loader = custom_problem_loader;
                    options_store.custom_problem_names = custom_problem_names;
                    options = rmfield(options, 'custom_problem_loader');
                    options = rmfield(options, 'custom_problem_names');
                elseif isfield(options, 'custom_problem_loader') || isfield(options, 'custom_problem_names')
                    error("MATLAB:benchmark:LoaderAndNamesNotSameTime", ...
                    "`custom_problem_loader` and `custom_problem_names` must be provided at the same time.");
                else
                    custom_problem_loader = {};
                    custom_problem_names = {};
                end
            end
        else
            error("MATLAB:benchmark:SecondArgumentWrongType", ...
            "The second argument for `benchmark` must be a feature name or a struct of options.");
        end
    else
        error("MATLAB:benchmark:TooMuchInput", ...
        "Invalid number of arguments. `benchmark` function at most takes two arguments.");
    end

    % Preprocess the solvers.
    if ~iscell(solvers) || ~all(cellfun(@(s) isa(s, 'function_handle'), solvers))
        error("MATLAB:benchmark:solversWrongType", "The first argument for `benchmark` must be a cell array of function handles.");
    end
    if numel(solvers) < 2
        error("MATLAB:benchmark:solversAtLeastTwo", "The first argument for `benchmark` must be a cell array of at least two function handles since we need to compare at least two solvers.");
    end

    % Preprocess the feature_name.
    if ~ischarstr(feature_name)
        % feature_name must be a char or string.
        error("MATLAB:benchmark:feature_nameNotcharstr", "The field `feature_name` of `options` for `benchmark` must be a char or string.");
    end
    % Convert the char or string to a char of lower case.
    feature_name = char(lower(feature_name));
    valid_feature_names = cellfun(@(x) x.value, num2cell(enumeration('FeatureName')), 'UniformOutput', false);
    if ~ismember(feature_name, valid_feature_names)
        error("MATLAB:benchmark:feature_nameNotValid", "The field `feature_name` of `options` for `benchmark` must be one of the valid feature names: %s.", strjoin(valid_feature_names, ', '));
    end

    % Preprocess the solver_names. If it is not provided, we use solvers' names as solver_names.
    if ~exist('solver_names', 'var')
        solver_names = cellfun(@(s) func2str(s), solvers, 'UniformOutput', false);
    end
    if ~iscell(solver_names) || ~all(cellfun(@(l) ischarstr(l), solver_names))
        error("MATLAB:benchmark:solver_namesNotCellOfcharstr", "The field `solver_names` of `options` for `benchmark` must be a cell of chars or strings.");
    end
    if numel(solver_names) ~= 0 && numel(solver_names) ~= numel(solvers)
        error("MATLAB:benchmark:solver_namesAndsolversLengthNotSame", "The number of the field `solver_names` of `options` for `benchmark` must equal the number of solvers.");
    end
    if numel(solver_names) == 0
        solver_names = cellfun(@(s) func2str(s), solvers, 'UniformOutput', false);
    end

    % Preprocess the custom problems.
    if ~isempty(custom_problem_loader) && ~isa(custom_problem_loader, 'function_handle')
        error("MATLAB:benchmark:customloaderNotFunctionHandle", "The field `custom_problem_loader` of `options` for `benchmark` must be a function handle.");
    end
    if ~isempty(custom_problem_names)
        if ~ischarstr(custom_problem_names) && ~(iscell(custom_problem_names) && all(cellfun(@ischarstr, custom_problem_names)))
            error("MATLAB:benchmark:customnamesNotcharstrOrCellOfcharstr", "The field `custom_problem_names` of `options` for `benchmark` must be a cell array of chars or strings.");
        end
        if ischarstr(custom_problem_names)
            custom_problem_names = {custom_problem_names};
        end
    end
    if ~isempty(custom_problem_loader) && ~isempty(custom_problem_names)
        try
            [~, p] = evalc('custom_problem_loader(custom_problem_names{1})');
        catch
            p = [];
        end
        if isempty(p) || ~isa(p, 'Problem')
            error("MATLAB:benchmark:customloaderNotAcceptcustomnames", "The `custom_problem_loader` failed to load the first custom problem %s.", custom_problem_names{1});
        end
    end

    % Set default options.
    profile_options = getDefaultProfileOptions();
    feature_options = struct();
    cutest_options = getDefaultCutestOptions();

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%% Parse options for feature, cutest, and profile. %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fieldNames = fieldnames(options);
    for i_field = 1:numel(fieldNames)
        key = fieldNames{i_field};
        value = options.(key);

        % We can also use: validFeatureOptionKeys = {enumeration('FeatureOptionKey').value};  
        % However, it only works for MATLAB R2021b or later.
        validFeatureOptionKeys = cellfun(@(x) x.value, num2cell(enumeration('FeatureOptionKey')), 'UniformOutput', false);
        validCutestOptionKeys = cellfun(@(x) x.value, num2cell(enumeration('CutestOptionKey')), 'UniformOutput', false);
        validProfileOptionKeys = cellfun(@(x) x.value, num2cell(enumeration('ProfileOptionKey')), 'UniformOutput', false);

        if ismember(key, validFeatureOptionKeys)
            feature_options.(key) = value;
        elseif ismember(key, validCutestOptionKeys)
            cutest_options.(key) = value;
        elseif ismember(key, validProfileOptionKeys)
            profile_options.(key) = value;
        else
            error("MATLAB:benchmark:UnknownOptions", "Unknown `option` for `benchmark`: %s", key);
        end
    end

    % Note: the validity of the feature options has been checked in the Feature constructor, so we
    % do not need to check it here.

    % Check whether the cutest options are valid.
    cutest_options = checkValidityCutestOptions(cutest_options);

    % Check whether the profile options are valid.
    profile_options = checkValidityProfileOptions(profile_options, solvers);

    % Store the options for later reproduction.
    feature_option_keys = fieldnames(feature_options);
    for i_field = 1:numel(feature_option_keys)
        key = feature_option_keys{i_field};
        options_store.(key) = feature_options.(key);
    end
    cutest_option_keys = fieldnames(cutest_options);
    for i_field = 1:numel(cutest_option_keys)
        key = cutest_option_keys{i_field};
        options_store.(key) = cutest_options.(key);
    end
    profile_option_keys = fieldnames(profile_options);
    for i_field = 1:numel(profile_option_keys)
        key = profile_option_keys{i_field};
        options_store.(key) = profile_options.(key);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%% Use cutest_options to select problems. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    cutest_problem_names = loadCutestNames(cutest_options, cutest_problem_names, custom_problem_loader, ...
    custom_problem_names);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%% Set the default values for plotting. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Create the directory to store the results.
    path_out = setSavingPath(profile_options);

    % Set the default values for plotting.
    set(groot, 'DefaultLineLineWidth', 1);
    set(groot, 'DefaultAxesFontSize', 12);
    set(groot, 'DefaultAxesFontName', 'Arial');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%% Start the computation of the profiles. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Build feature.
    feature = Feature(feature_name, feature_options);

    % Preprocess the feature_stamp. If it is not provided, we use default feature_stamps for
    % different features.
    if ~exist('feature_stamp', 'var') || isempty(feature_stamp)
        feature_stamp = setDefaultFeatureStamp(feature);
    end
    if ~ischarstr(feature_stamp)
        error("MATLAB:benchmark:feature_stampNotcharstr", "The field `feature_stamp` of `options` for `benchmark` must be a char or string.");
    end
    is_valid_foldername = @(x) ischarstr(x) && ~isempty(x) && all(ismember(char(x), ['a':'z', 'A':'Z', '0':'9', '_', '-', '.']));
    if ~is_valid_foldername(feature_stamp)
        error("MATLAB:benchmark:feature_stampNotValid", "The field 'feature_stamp' of options should be a char or a string satisfying the strict file name requirements (only containing letters, numbers, underscores, hyphens, and dots).");
    end
    profile_options.feature_stamp = feature_stamp;

    % Create the directory to store the results. If it already exists, overwrite it.
    path_feature = fullfile(path_out, feature_stamp);
    if ~exist(path_feature, 'dir')
        mkdir(path_feature);
    else
        rmdir(path_feature, 's');
        mkdir(path_feature);
    end
    path_hist_plots = fullfile(path_feature, 'history_plots');
    if ~exist(path_hist_plots, 'dir')
        mkdir(path_hist_plots);
    end

    % Create the directory to store options and log files.
    path_log = fullfile(path_feature, 'test_log');
    if ~exist(path_log, 'dir')
        mkdir(path_log);
    else
        rmdir(path_log, 's');
        mkdir(path_log);
    end
    try
        save(fullfile(path_log, 'options_store.mat'), 'options_store');
    catch
        fprintf("INFO: Failed to save the `options` of the current experiment.\n");
    end
    log_file = fullfile(path_log, 'log.txt');
    diary(log_file);

    % We try to copy the script or function that calls the benchmark function to the log directory.
    try
        calling_script = dbstack(1, '-completenames');
        if ~isempty(calling_script)
            copyfile(calling_script.file, path_log);
            fprintf("INFO: The script or function that calls `benchmark` function is copied to: %s.\n\n", path_log);
        end
    catch
        fprintf("INFO: Failed to copy the script or function that calls `benchmark` function to the log directory.\n\n");
    end

    % Solve all the problems.
    if ~profile_options.(ProfileOptionKey.SILENT.value)
        fprintf('INFO: Starting the computation of the "%s" profiles.\n', feature.name);
    end
    [fun_histories, maxcv_histories, fun_out, maxcv_out, fun_init, maxcv_init, n_eval, problem_names, problem_dimensions, time_processes, problem_unsolved] = solveAllProblems(cutest_problem_names, custom_problem_loader, custom_problem_names, solvers, solver_names, feature, profile_options, true, path_hist_plots);
    merit_histories = computeMeritValues(fun_histories, maxcv_histories, maxcv_init);
    merit_out = computeMeritValues(fun_out, maxcv_out, maxcv_init);
    merit_init = computeMeritValues(fun_init, maxcv_init, maxcv_init);

    % If there are no problems solved, skip the rest of the code, print a message, and return.
    if isempty(problem_names)
        if ~profile_options.(ProfileOptionKey.SILENT.value)
            fprintf('INFO: No problems were solved for the "%s" feature.\n', feature.name);
        end
        diary off;
        return;
    end

    % If there is only one problem, we will not compute the performance profiles, data profiles, and
    % log-ratio profiles.
    if numel(problem_names) == 1
        % We move the history plots to the feature directory.
        try
            movefile(fullfile(path_hist_plots, '*'), path_feature);
            rmdir(path_hist_plots, 's');
            if ~profile_options.(ProfileOptionKey.SILENT.value)
                fprintf('\nINFO: Detailed results stored in %s\n', path_feature);
            end
        catch
        end
        diary off;
        return;
    end

    % Determine the least merit value for each problem.
    merit_min = min(min(min(merit_histories, [], 4, 'omitnan'), [], 3, 'omitnan'), [], 2, 'omitnan');
    if feature.run_plain && profile_options.(ProfileOptionKey.RUN_PLAIN.value)
        feature_plain = Feature(FeatureName.PLAIN.value);
        if ~profile_options.(ProfileOptionKey.SILENT.value)
            fprintf('\nINFO: Starting the computation of the profiles under "plain" feature.\n');
        end
        [fun_histories_plain, maxcv_histories_plain, ~, ~, ~, ~, ~, problem_names_plain, ~, time_processes_plain] = solveAllProblems(cutest_problem_names, custom_problem_loader, custom_problem_names, solvers, solver_names, feature_plain, profile_options, false, {});
        merit_histories_plain = computeMeritValues(fun_histories_plain, maxcv_histories_plain, maxcv_init);
        merit_min_plain = min(min(min(merit_histories_plain, [], 4, 'omitnan'), [], 3, 'omitnan'), [], 2, 'omitnan');
        for i_problem = 1:numel(problem_names)
            % Check whether the problem is solved under the plain feature.
            if ismember(problem_names{i_problem}, problem_names_plain)
                % Find the index of the problem in the plain feature.
                idx = find(strcmp(problem_names{i_problem}, problem_names_plain), 1);
                merit_min(i_problem) = min(merit_min(i_problem), merit_min_plain(idx), 'omitnan');
                time_processes(i_problem) = time_processes(i_problem) + time_processes_plain(idx);
            end
        end
    end

    % Create the directories for the performance profiles, data profiles, and log-ratio profiles.
    path_perf_hist = fullfile(path_feature, 'detailed_profiles', 'perf_history-based');
    path_data_hist = fullfile(path_feature, 'detailed_profiles', 'data_history-based');
    path_log_ratio_hist = fullfile(path_feature, 'detailed_profiles', 'log-ratio_history-based');
    path_perf_out = fullfile(path_feature, 'detailed_profiles', 'perf_output-based');
    path_data_out = fullfile(path_feature, 'detailed_profiles', 'data_output-based');
    path_log_ratio_out = fullfile(path_feature, 'detailed_profiles', 'log-ratio_output-based');
    
    if ~exist(path_perf_hist, 'dir')
        mkdir(path_perf_hist);
    end
    if ~exist(path_data_hist, 'dir')
        mkdir(path_data_hist);
    end
    if ~exist(path_perf_out, 'dir')
        mkdir(path_perf_out);
    end
    if ~exist(path_data_out, 'dir')
        mkdir(path_data_out);
    end

    % Store the names of the problems.
    path_txt = fullfile(path_feature, 'problems.txt');
    [~, idx] = sort(lower(problem_names));
    sorted_problem_names = problem_names(idx);
    sorted_time_processes = time_processes(idx);
    fid = fopen(path_txt, 'w');
    if fid == -1
        error("MATLAB:benchmark:FileCannotOpen", "Cannot open the file %s.", path_txt);
    end
    for i = 1:length(sorted_problem_names)
        count = fprintf(fid, "%s: %.2f seconds\n", sorted_problem_names{i}, sorted_time_processes(i));
        if count < 0
            error("MATLAB:benchmark:FailToEditFile", "Failed to record data for %s.", sorted_problem_names{i});
        end
    end
    if ~isempty(problem_unsolved)
        fprintf(fid, "\n");
        fprintf(fid, "Unsolved problems:\n");
        for i = 1:length(problem_unsolved)
            count = fprintf(fid, "%s\n", problem_unsolved{i});
            if count < 0
                fprintf("INFO: Failed to record data for %s.", problem_unsolved{i});
            end
        end
    end
    fclose(fid);

    % Merge all the pdf files in path_hist_plots to a single pdf file.
    if ~profile_options.(ProfileOptionKey.SILENT.value)
        fprintf('\nINFO: Merging all the history plots to a single PDF file.\n');
    end
    try
        mergePdfs(path_hist_plots, 'history_plots_summary.pdf', path_feature);
    catch
        warning('INFO: Failed to merge the history plots to a single PDF file.');
    end

    if ~profile_options.(ProfileOptionKey.SILENT.value)
        fprintf('\nINFO: Detailed results stored in %s\n\n', path_feature);
    end

    [n_problems, n_solvers, n_runs, ~] = size(merit_histories);
    if n_solvers <= 2
        if ~exist(path_log_ratio_hist, 'dir')
            mkdir(path_log_ratio_hist);
        end
        if ~exist(path_log_ratio_out, 'dir')
            mkdir(path_log_ratio_out);
        end
    end

    max_tol_order = profile_options.(ProfileOptionKey.MAX_TOL_ORDER.value);
    tolerances = 10.^(-1:-1:-max_tol_order);
    pdf_perf_hist_summary = fullfile(path_feature, 'perf_hist.pdf');
    pdf_perf_out_summary = fullfile(path_feature, 'perf_out.pdf');
    pdf_data_hist_summary = fullfile(path_feature, 'data_hist.pdf');
    pdf_data_out_summary = fullfile(path_feature, 'data_out.pdf');
    pdf_log_ratio_hist_summary = fullfile(path_feature, 'log-ratio_hist.pdf');
    pdf_log_ratio_out_summary = fullfile(path_feature, 'log-ratio_out.pdf');

    % Create profiles.
    warning('off');
    n_rows = 0;
    is_perf = profile_options.(ProfileOptionKey.SUMMARIZE_PERFORMANCE_PROFILES.value);
    is_data = profile_options.(ProfileOptionKey.SUMMARIZE_DATA_PROFILES.value);
    is_log_ratio = profile_options.(ProfileOptionKey.SUMMARIZE_LOG_RATIO_PROFILES.value) && (n_solvers <= 2);
    is_output_based = profile_options.(ProfileOptionKey.SUMMARIZE_OUTPUT_BASED_PROFILES.value);
    if is_perf
        n_rows = n_rows + 1;
    end
    if is_data
        n_rows = n_rows + 1;
    end
    if is_log_ratio
        n_rows = n_rows + 1;
    end
    if is_output_based
        multiplier = 2;
    else
        multiplier = 1;
    end
    defaultFigurePosition = get(0, 'DefaultFigurePosition');
    default_width = defaultFigurePosition(3);
    default_height = defaultFigurePosition(4);
    fig_summary = figure('Position', [defaultFigurePosition(1:2), profile_options.(ProfileOptionKey.MAX_TOL_ORDER.value) * default_width, multiplier * n_rows * default_height], 'visible', 'off');
    T_summary = tiledlayout(fig_summary, multiplier, 1, 'Padding', 'compact', 'TileSpacing', 'compact');
    T_feature_stamp = strrep(feature_stamp, '_', '\_');
    T_title = ['Profiles with the ``', T_feature_stamp, '" feature'];
    summary_width = profile_options.(ProfileOptionKey.MAX_TOL_ORDER.value) * default_width;
    summary_fontsize = 1.5 * summary_width / length(T_title);
    title(T_summary, T_title, 'Interpreter', 'latex', 'FontSize', summary_fontsize);
    % Use gobjects to create arrays of handles and axes.
    t_summary = gobjects(multiplier, 1);
    axs_summary = gobjects([multiplier, 1, n_rows, profile_options.(ProfileOptionKey.MAX_TOL_ORDER.value)]);
    i_axs = 0;
    for i = 1:multiplier
        t_summary(i) = tiledlayout(T_summary, n_rows, profile_options.(ProfileOptionKey.MAX_TOL_ORDER.value), ...
        'Padding', 'compact', 'TileSpacing', 'compact');
        t_summary(i).Layout.Tile = i;
        for j = 1:n_rows * profile_options.(ProfileOptionKey.MAX_TOL_ORDER.value)
            i_axs = i_axs + 1;
            axs_summary(i_axs) = nexttile(t_summary(i));
        end
    end
    ylabel(t_summary(1), "History-based profiles", 'Interpreter', 'latex', 'FontSize', 20);
    if is_output_based
        ylabel(t_summary(2), "Output-based profiles", 'Interpreter', 'latex', 'FontSize', 20);
    end

    for i_profile = 1:profile_options.(ProfileOptionKey.MAX_TOL_ORDER.value)
        tolerance = tolerances(i_profile);
        [tolerance_str, tolerance_latex] = formatFloatScientificLatex(tolerance, 1);
        if ~profile_options.(ProfileOptionKey.SILENT.value)
            fprintf("INFO: Creating profiles for tolerance %s.\n", tolerance_str);
        end
        tolerance_label = ['$\mathrm{tol} = ' tolerance_latex '$'];

        work_hist = NaN(n_problems, n_solvers, n_runs);
        work_out = NaN(n_problems, n_solvers, n_runs);
        for i_problem = 1:n_problems
            for i_solver = 1:n_solvers
                for i_run = 1:n_runs
                    if isfinite(merit_min(i_problem))
                        threshold = max(tolerance * merit_init(i_problem) + (1 - tolerance) * merit_min(i_problem), ...
                        merit_min(i_problem));
                    else
                        threshold = -Inf;
                    end
                    if min(merit_histories(i_problem, i_solver, i_run, :), [], 'omitnan') <= threshold
                        work_hist(i_problem, i_solver, i_run) = find(merit_histories(i_problem, i_solver, i_run, :) ...
                        <= threshold, 1, 'first');
                    end
                    if merit_out(i_problem, i_solver, i_run) <= threshold
                        work_out(i_problem, i_solver, i_run) = n_eval(i_problem, i_solver, i_run);
                    end
                end
            end
        end

        % Draw the profiles.
        cell_axs_summary_out = {};
        if is_perf && is_data && is_log_ratio
            cell_axs_summary_hist = {axs_summary(i_profile), axs_summary(i_profile + max_tol_order), ...
            axs_summary(i_profile + 2 * max_tol_order)};
            if is_output_based
                cell_axs_summary_out = {axs_summary(i_profile + 3 * max_tol_order), ...
                axs_summary(i_profile + 4 * max_tol_order), axs_summary(i_profile + 5 * max_tol_order)};
            end
        elseif (is_perf && is_data) || (is_perf && is_log_ratio) || (is_data && is_log_ratio)
            cell_axs_summary_hist = {axs_summary(i_profile), axs_summary(i_profile + max_tol_order)};
            if is_output_based
                cell_axs_summary_out = {axs_summary(i_profile + 2 * max_tol_order), ...
                axs_summary(i_profile + 3 * max_tol_order)};
            end
        elseif is_perf || is_data || is_log_ratio
            cell_axs_summary_hist = {axs_summary(i_profile)};
            if is_output_based
                cell_axs_summary_out = {axs_summary(i_profile + max_tol_order)};
            end
        end

        processed_solver_names = cellfun(@(s) strrep(s, '_', '\_'), solver_names, 'UniformOutput', false);
        [fig_perf_hist, fig_data_hist, fig_log_ratio_hist] = drawProfiles(work_hist, problem_dimensions, processed_solver_names, tolerance_label, cell_axs_summary_hist, true, is_perf, is_data, is_log_ratio, profile_options);
        [fig_perf_out, fig_data_out, fig_log_ratio_out] = drawProfiles(work_out, problem_dimensions, processed_solver_names, tolerance_label, cell_axs_summary_out, is_output_based, is_perf, is_data, is_log_ratio, profile_options);

        eps_perf_hist = fullfile(path_perf_hist, ['perf_hist_' int2str(i_profile) '.eps']);
        print(fig_perf_hist, eps_perf_hist, '-depsc');
        pdf_perf_hist = fullfile(path_perf_hist, ['perf_hist_' int2str(i_profile) '.pdf']);
        print(fig_perf_hist, pdf_perf_hist, '-dpdf');
        eps_perf_out = fullfile(path_perf_out, ['perf_out_' int2str(i_profile) '.eps']);
        print(fig_perf_out, eps_perf_out, '-depsc');
        pdf_perf_out = fullfile(path_perf_out, ['perf_out_' int2str(i_profile) '.pdf']);
        print(fig_perf_out, pdf_perf_out, '-dpdf');
        eps_data_hist = fullfile(path_data_hist, ['data_hist_' int2str(i_profile) '.eps']);
        print(fig_data_hist, eps_data_hist, '-depsc');
        pdf_data_hist = fullfile(path_data_hist, ['data_hist_' int2str(i_profile) '.pdf']);
        print(fig_data_hist, pdf_data_hist, '-dpdf');
        eps_data_out = fullfile(path_data_out, ['data_out_' int2str(i_profile) '.eps']);
        print(fig_data_out, eps_data_out, '-depsc');
        pdf_data_out = fullfile(path_data_out, ['data_out_' int2str(i_profile) '.pdf']);
        print(fig_data_out, pdf_data_out, '-dpdf');
        if n_solvers <= 2
            eps_log_ratio_hist = fullfile(path_log_ratio_hist, ['log-ratio_hist_' int2str(i_profile) '.eps']);
            print(fig_log_ratio_hist, eps_log_ratio_hist, '-depsc');
            pdf_log_ratio_hist = fullfile(path_log_ratio_hist, ['log-ratio_hist_' int2str(i_profile) '.pdf']);
            print(fig_log_ratio_hist, pdf_log_ratio_hist, '-dpdf');
        end
        if n_solvers <= 2
            eps_log_ratio_out = fullfile(path_log_ratio_out, ['log-ratio_out_' int2str(i_profile) '.eps']);
            print(fig_log_ratio_out, eps_log_ratio_out, '-depsc');
            pdf_log_ratio_out = fullfile(path_log_ratio_out, ['log-ratio_out_' int2str(i_profile) '.pdf']);
            print(fig_log_ratio_out, pdf_log_ratio_out, '-dpdf');
        end
        if i_profile == 1
            exportgraphics(fig_perf_hist, pdf_perf_hist_summary, 'ContentType', 'vector');
            exportgraphics(fig_perf_out, pdf_perf_out_summary, 'ContentType', 'vector');
            exportgraphics(fig_data_hist, pdf_data_hist_summary, 'ContentType', 'vector');
            exportgraphics(fig_data_out, pdf_data_out_summary, 'ContentType', 'vector');
            if n_solvers <= 2
                exportgraphics(fig_log_ratio_hist, pdf_log_ratio_hist_summary, 'ContentType', 'vector');
            end
            if ~isempty(fig_log_ratio_out)
                exportgraphics(fig_log_ratio_out, pdf_log_ratio_out_summary, 'ContentType', 'vector');
            end
        else
            exportgraphics(fig_perf_hist, pdf_perf_hist_summary, 'ContentType', 'vector', 'Append', true);
            exportgraphics(fig_perf_out, pdf_perf_out_summary, 'ContentType', 'vector', 'Append', true);
            exportgraphics(fig_data_hist, pdf_data_hist_summary, 'ContentType', 'vector', 'Append', true);
            exportgraphics(fig_data_out, pdf_data_out_summary, 'ContentType', 'vector', 'Append', true);
            if n_solvers <= 2
                exportgraphics(fig_log_ratio_hist, pdf_log_ratio_hist_summary, 'ContentType', 'vector', 'Append', true);
            end
            if ~isempty(fig_log_ratio_out)
                exportgraphics(fig_log_ratio_out, pdf_log_ratio_out_summary, 'ContentType', 'vector', 'Append', true);
            end
        end

        % Close the figures.
        close(fig_perf_hist);
        close(fig_perf_out);
        close(fig_data_hist);
        close(fig_data_out);
        if n_solvers <= 2
            close(fig_log_ratio_hist);
        end
        if ~isempty(fig_log_ratio_out)
            close(fig_log_ratio_out);
        end

    end

    % Store the summary pdf. We will name the summary pdf as "summary_feature_name.pdf" and store it under path_feature.
    % We will also put a "summary.pdf" in the path_out directory, which will be a merged pdf of all the "summary_feature_name.pdf" under path_out following the order of the feature_stamp.
    exportgraphics(fig_summary, fullfile(path_feature, ['summary_' feature_name '.pdf']), 'ContentType', 'vector');
    % List all summary PDF files in the output path and its subdirectories.
    summary_files = dir(fullfile(path_out, '**', 'summary_*.pdf'));
    % Sort the summary PDF files by their folder names.
    [~, idx] = sort({summary_files.folder});
    summary_files = summary_files(idx);
    % Merge all the summary PDF files to a single PDF file.
    delete(fullfile(path_out, 'summary.pdf'));
    for i_file = 1:numel(summary_files)
        copyfile(fullfile(summary_files(i_file).folder, summary_files(i_file).name), path_out);
        mergePdfs(path_out, 'summary.pdf', path_out);
        delete(fullfile(path_out, summary_files(i_file).name));
    end

    warning('on');

    % Close the figures.
    close(fig_summary);
    if ~profile_options.(ProfileOptionKey.SILENT.value)
        fprintf('\nINFO: Summary stored in %s\n', path_out);
    end

    diary off;

end

% Following code is modified from the code provided by Benjamin Großmann (2024). Merge PDF-Documents
% (https://www.mathworks.com/matlabcentral/fileexchange/89127-merge-pdf-documents), MATLAB Central
% File Exchange. Retrieved November 12, 2024.
function mergePdfs(file_path, output_file_name, output_path)

    fileNames = dir(fullfile(file_path, '*.pdf'));
    fileNames = {fileNames.name};
    fileNames = cellfun(@(f) fullfile(file_path, f), fileNames, 'UniformOutput', false);

    memSet = org.apache.pdfbox.io.MemoryUsageSetting.setupMainMemoryOnly();
    merger = org.apache.pdfbox.multipdf.PDFMergerUtility;
    
    cellfun(@(f) merger.addSource(f), fileNames)
    
    merger.setDestinationFileName(fullfile(output_path, output_file_name));
    merger.mergeDocuments(memSet)
end

function feature_stamp = setDefaultFeatureStamp(feature)
    % Generate a feature stamp to represent the feature with its options.

    switch feature.name
        case FeatureName.PERTURBED_X0.value
            % feature_name + noise_level + (distribution if it is gaussian or spherical)
            feature_stamp = sprintf('%s_%g', feature.name, feature.options.(FeatureOptionKey.NOISE_LEVEL.value));
            if ischarstr(feature.options.(FeatureOptionKey.DISTRIBUTION.value)) && ismember(feature.options.(FeatureOptionKey.DISTRIBUTION.value), {'gaussian', 'spherical'})
                feature_stamp = sprintf('%s_%s', feature_stamp, feature.options.(FeatureOptionKey.DISTRIBUTION.value));
            end
        case FeatureName.NOISY.value
            % feature_name + noise_level + noise_type + (distribution if it is gaussian or uniform)
            feature_stamp = sprintf('%s_%g_%s', feature.name, feature.options.(FeatureOptionKey.NOISE_LEVEL.value), feature.options.(FeatureOptionKey.NOISE_TYPE.value));
            if ischarstr(feature.options.(FeatureOptionKey.DISTRIBUTION.value)) && ismember(feature.options.(FeatureOptionKey.DISTRIBUTION.value), {'gaussian', 'uniform'})
                feature_stamp = sprintf('%s_%s', feature_stamp, feature.options.(FeatureOptionKey.DISTRIBUTION.value));
            end
        case FeatureName.TRUNCATED.value
            % feature_name + significant_digits + (perturbed_trailing_zeros if it is true)
            feature_stamp = sprintf('%s_%d', feature.name, feature.options.(FeatureOptionKey.SIGNIFICANT_DIGITS.value));
            if feature.options.(FeatureOptionKey.PERTURBED_TRAILING_ZEROS.value)
                feature_stamp = sprintf('%s_perturbed_trailing_zeros', feature_stamp);
            end
        case FeatureName.LINEARLY_TRANSFORMED.value
            % feature_name + (rotated if it is true) + (condition_factor if it is not 0)
            feature_stamp = feature.name;
            if feature.options.(FeatureOptionKey.ROTATED.value)
                feature_stamp = sprintf('%s_rotated', feature_stamp);
            end
            if feature.options.(FeatureOptionKey.CONDITION_FACTOR.value) ~= 0
                feature_stamp = sprintf('%s_%g', feature_stamp, feature.options.(FeatureOptionKey.CONDITION_FACTOR.value));
            end
        case FeatureName.RANDOM_NAN.value
            % feature_name + nan_rate
            feature_stamp = sprintf('%s_%g', feature.name, feature.options.(FeatureOptionKey.NAN_RATE.value));
        case FeatureName.UNRELAXABLE_CONSTRAINTS.value
            % feature_name + (bounds if it is true) + (linear if it is true) + (nonlinear if it is true)
            feature_stamp = feature.name;
            if feature.options.(FeatureOptionKey.UNRELAXABLE_BOUNDS.value)
                feature_stamp = sprintf('%s_bounds', feature_stamp);
            end
            if feature.options.(FeatureOptionKey.UNRELAXABLE_LINEAR_CONSTRAINTS.value)
                feature_stamp = sprintf('%s_linear', feature_stamp);
            end
            if feature.options.(FeatureOptionKey.UNRELAXABLE_NONLINEAR_CONSTRAINTS.value)
                feature_stamp = sprintf('%s_nonlinear', feature_stamp);
            end
        case FeatureName.QUANTIZED.value
            % feature_name + mesh_size + (ground_truth if is_true it is true)
            feature_stamp = sprintf('%s_%g', feature.name, feature.options.(FeatureOptionKey.MESH_SIZE.value));
            if feature.options.(FeatureOptionKey.GROUND_TRUTH.value)
                feature_stamp = sprintf('%s_ground_truth', feature_stamp);
            end
        otherwise
            feature_stamp = feature.name;
    end
end