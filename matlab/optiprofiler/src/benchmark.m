function benchmark(solvers, varargin)
%BENCHMARKS creates the benchmark profiles.
%
%   The benchmark profiles include the performance and data profiles [1]_,
%   [2]_, [4]_, and the log-ratio profiles [3]_, [5]_. The log-ratio profiles
%   are available only when there are exactly two solvers.
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
%
%          benchmark(solvers)
%          benchmark(solvers, feature_names)
%          benchmark(solvers, options)
%          


    if nargin == 0
        error("MATLAB:benchmark:solverMustBeProvided", "solvers must be provided.");
    elseif nargin == 1
        feature_names = 'plain';
        labels = cellfun(@func2str, solvers, 'UniformOutput', false);
        cutest_problem_names = {};
        custom_problem_loader = {};
        custom_problem_names = {};
        options = struct();
    elseif nargin == 2
        if ischarstr(varargin{1}) || (iscell(varargin{1}) && all(cellfun(@ischarstr, varargin{1})))
            feature_names = varargin{1};
            labels = cellfun(@func2str, solvers, 'UniformOutput', false);
            cutest_problem_names = {};
            custom_problem_loader = {};
            custom_problem_names = {};
            options = struct();
        elseif isstruct(varargin{1})
            options = varargin{1};
            if isfield(options, 'feature_names')
                feature_names = options.feature_names;
                options = rmfield(options, 'feature_names');
            else
                feature_names = 'plain';
            end
            if isfield(options, 'labels')
                labels = options.labels;
                options = rmfield(options, 'labels');
            else
                labels = cellfun(@func2str, solvers, 'UniformOutput', false);
            end
            if isfield(options, 'cutest_problem_names')
                cutest_problem_names = options.cutest_problem_names;
                options = rmfield(options, 'cutest_problem_names');
            else
                cutest_problem_names = {};
            end
            if isfield(options, 'custom_problem_loader') && isfield(options, 'custom_problem_names')
                custom_problem_loader = options.custom_problem_loader;
                custom_problem_names = options.custom_problem_names;
                options = rmfield(options, 'custom_problem_loader');
                options = rmfield(options, 'custom_problem_names');
            elseif isfield(options, 'custom_problem_loader') || isfield(options, 'custom_problem_names')
                error("MATLAB:benchmark:LoaderAndNamesNotSameTime", "custom_problem_loader and custom_problem_names must be provided at the same time.");
            else
                custom_problem_loader = {};
                custom_problem_names = {};
            end
        else
            error("MATLAB:benchmark:SecondArgumentWrongType", "The second argument must be a cell array of feature names or a struct of options.");
        end
    else
        error("MATLAB:benchmark:TooMuchInput", "Invalid number of arguments. The function must be called with one, two, or three arguments.");
    end

    % Preprocess the solvers.
    if ~iscell(solvers) || ~all(cellfun(@(s) isa(s, 'function_handle'), solvers))
        error("MATLAB:benchmark:solversWrongType", "The solvers must be a cell array of function handles.");
    end
    if numel(solvers) < 2
        error("MATLAB:benchmark:solversAtLeastTwo", "At least two solvers must be given.");
    end

    % Preprocess the labels.
    if ~iscell(labels) || ~all(cellfun(@(l) ischarstr(l), labels))
        error("MATLAB:benchmark:labelsNotCellOfcharstr", "The labels must be a cell of chars or strings.");
    end
    if numel(labels) ~= 0 && numel(labels) ~= numel(solvers)
        error("MATLAB:benchmark:labelsAndsolversLengthNotSame", "The number of labels must equal the number of solvers.");
    end
    if numel(labels) == 0
        labels = cellfun(@func2str, solvers, 'UniformOutput', false);
    end

    % Preprocess the custom problems.
    if ~isempty(custom_problem_loader) && ~isa(custom_problem_loader, 'function_handle')
        error("MATLAB:benchmark:customloaderNotFunctionHandle", "The custom problem loader must be a function handle.");
    end
    if ~isempty(custom_problem_loader)
        if isempty(custom_problem_names)
            error("MATLAB:benchmark:customnamesCanNotBeEmptyWhenHavingcustomloader", "The custom problem names must be provided.");
        else
            try
                [~, p] = evalc('custom_problem_loader(custom_problem_names{1})');
            catch
                p = [];
            end
            if isempty(p) || ~isa(p, 'Problem')
                error("MATLAB:benchmark:customloaderNotAcceptcustomnames", "The custom problem loader must be able to accept one signature 'custom_problem_names'. The first problem %s could not be loaded, or custom problem loader did not return a Problem object.", custom_problem_names{1});
            end
        end
    elseif ~isempty(custom_problem_names)
        error("MATLAB:benchmark:customloaderCanNotBeEmptyWhenHavingcustomnames", "A custom problem loader must be given to load custom problems.");
    end
    if ~isempty(custom_problem_names)
        if ~ischarstr(custom_problem_names) && ~(iscell(custom_problem_names) && all(cellfun(@ischarstr, custom_problem_names)))
            error("MATLAB:benchmark:customnamesNotcharstrOrCellOfcharstr", "The custom problem names must be a cell array of chars or strings.");
        end
        if ischarstr(custom_problem_names)
            custom_problem_names = {custom_problem_names};
        end
        custom_problem_names = cellfun(@char, custom_problem_names, 'UniformOutput', false);  % Convert to cell array of chars.
    end

    % Set default profile options.
    if exist('parcluster', 'file') == 2
        myCluster = parcluster('local');
        nb_cores = myCluster.NumWorkers;
    else
        nb_cores = 1;
    end
    profile_options.(ProfileOptionKey.N_JOBS.value) = nb_cores;
    profile_options.(ProfileOptionKey.BENCHMARK_ID.value) = '.';
    profile_options.(ProfileOptionKey.RANGE_TYPE.value) = 'minmax';
    profile_options.(ProfileOptionKey.STD_FACTOR.value) = 1;
    profile_options.(ProfileOptionKey.SAVEPATH.value) = pwd;
    profile_options.(ProfileOptionKey.MAX_TOL_ORDER.value) = 10;
    profile_options.(ProfileOptionKey.MAX_EVAL_FACTOR.value) = 500;
    profile_options.(ProfileOptionKey.PROJECT_X0.value) = false;
    profile_options.(ProfileOptionKey.RUN_PLAIN.value) = true;
    profile_options.(ProfileOptionKey.SUMMARIZE_PERFORMANCE_PROFILES.value) = true;
    profile_options.(ProfileOptionKey.SUMMARIZE_DATA_PROFILES.value) = true;
    profile_options.(ProfileOptionKey.SUMMARIZE_LOG_RATIO_PROFILES.value) = false;
    
    % Initialize the options for feature and cutest.
    feature_options = struct();
    cutest_options = struct();

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%% Parse options for feature, cutest, and profile. %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fieldNames = fieldnames(options);
    for i_field = 1:numel(fieldNames)
        key = fieldNames{i_field};
        value = options.(key);

        % validFeatureOptionKeys = {enumeration('FeatureOptionKey').value};  % Only for MATLAB R2021b or later.
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
            error("MATLAB:benchmark:UnknownOptions", "Unknown option: %s", key);
        end
    end

    % The validity of the feature options will be checked in the Feature constructor, so we do not need to check it here.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Check whether the cutest options are valid. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Judge whether cutest_options.problem_type is among all possible problem types.
    if isfield(cutest_options, CutestOptionKey.PROBLEM_TYPE.value)
        if ~ischarstr(cutest_options.(CutestOptionKey.PROBLEM_TYPE.value))
            error("MATLAB:benchmark:problem_typeNotcharstr", "cutest_options.problem_type should be a char or a string.");
        else
            % Convert to lower case CHAR.
            cutest_options.(CutestOptionKey.PROBLEM_TYPE.value) = lower(char(cutest_options.(CutestOptionKey.PROBLEM_TYPE.value)));
            % Check whether the problem type belongs to four types ('u', 'b', 'l', 'n') and their combinations.
            if ~all(ismember(cutest_options.(CutestOptionKey.PROBLEM_TYPE.value), 'ubln'))
                error("MATLAB:benchmark:problem_typeNotubln", "cutest_options.problem_type should be a string containing only 'u', 'b', 'l', 'n'.");
            end
        end
    end
    % Judge whether cutest_options.mindim is a integer greater or equal to 1.
    if isfield(cutest_options, CutestOptionKey.MINDIM.value)
        if ~isintegerscalar(cutest_options.(CutestOptionKey.MINDIM.value)) || cutest_options.(CutestOptionKey.MINDIM.value) < 1
            error("MATLAB:benchmark:mindimNotValid", "cutest_options.mindim should be a integer greater or equal to 1.");
        end
    end
    % Judge whether cutest_options.maxdim is a integer greater or equal to 1, or equal to Inf.
    if isfield(cutest_options, CutestOptionKey.MAXDIM.value)
        if ~isintegerscalar(cutest_options.(CutestOptionKey.MAXDIM.value)) || (cutest_options.(CutestOptionKey.MAXDIM.value) < 1 && cutest_options.(CutestOptionKey.MAXDIM.value) ~= Inf)
            error("MATLAB:benchmark:maxdimNotValid", "cutest_options.maxdim should be a integer greater or equal to 1, or equal to Inf.");
        end
    end
    % Judge whether cutest_options.mindim is smaller or equal to cutest_options.maxdim.
    if isfield(cutest_options, CutestOptionKey.MINDIM.value) && isfield(cutest_options, CutestOptionKey.MAXDIM.value)
        if cutest_options.(CutestOptionKey.MINDIM.value) > cutest_options.(CutestOptionKey.MAXDIM.value)
            error("MATLAB:benchmark:maxdimSmallerThanmindim", "cutest_options.mindim should be smaller or equal to cutest_options.maxdim.");
        end
    end
    % Judge whether cutest_options.mincon is a integer greater or equal to 0.
    if isfield(cutest_options, CutestOptionKey.MINCON.value)
        if ~isintegerscalar(cutest_options.(CutestOptionKey.MINCON.value)) || cutest_options.(CutestOptionKey.MINCON.value) < 0
            error("MATLAB:benchmark:minconNotValid", "cutest_options.mincon should be a integer greater or equal to 0.");
        end
    end
    % Judge whether cutest_options.maxcon is a integer greater or equal to 0, or equal to Inf.
    if isfield(cutest_options, CutestOptionKey.MAXCON.value)
        if ~isintegerscalar(cutest_options.(CutestOptionKey.MAXCON.value)) || (cutest_options.(CutestOptionKey.MAXCON.value) < 0 && cutest_options.(CutestOptionKey.MAXCON.value) ~= Inf)
            error("MATLAB:benchmark:maxconNotValid", "cutest_options.maxcon should be a integer greater or equal to 0, or equal to Inf.");
        end
    end
    % Judge whether cutest_options.mincon is smaller or equal to cutest_options.maxcon.
    if isfield(cutest_options, CutestOptionKey.MINCON.value) && isfield(cutest_options, CutestOptionKey.MAXCON.value)
        if cutest_options.(CutestOptionKey.MINCON.value) > cutest_options.(CutestOptionKey.MAXCON.value)
            error("MATLAB:benchmark:maxconSmallerThanmincon", "cutest_options.mincon should be smaller or equal to cutest_options.maxcon.");
        end
    end
    % Judge whether cutest_options.excludelist is a cell array of strings or chars.
    if isfield(cutest_options, CutestOptionKey.EXCLUDELIST.value)
        if ~iscell(cutest_options.(CutestOptionKey.EXCLUDELIST.value)) || ~all(cellfun(@ischarstr, cutest_options.(CutestOptionKey.EXCLUDELIST.value)))
            error("MATLAB:benchmark:excludelistNotCellOfcharstr", "cutest_options.excludelist should be a cell array of strings or chars.");
        end
        cutest_options.(CutestOptionKey.EXCLUDELIST.value) = cellfun(@char, cutest_options.(CutestOptionKey.EXCLUDELIST.value), 'UniformOutput', false);  % Convert to cell array of chars.
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Check whether the profile options are valid. %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Judge whether profile_options.n_jobs is a integer between 1 and nb_cores.
    if isfield(profile_options, ProfileOptionKey.N_JOBS.value)
        if ~isintegerscalar(profile_options.(ProfileOptionKey.N_JOBS.value))
            error("MATLAB:benchmark:n_jobsNotValid", "profile_options.n_jobs should be a integer.");
        elseif profile_options.(ProfileOptionKey.N_JOBS.value) < 1
            profile_options.(ProfileOptionKey.N_JOBS.value) = 1;
        elseif profile_options.(ProfileOptionKey.N_JOBS.value) > nb_cores
            profile_options.(ProfileOptionKey.N_JOBS.value) = nb_cores;
        else
            profile_options.(ProfileOptionKey.N_JOBS.value) = round(profile_options.(ProfileOptionKey.N_JOBS.value));
        end
    end
    % Judge whether profile_options.benchmark_id is a char or a string and satisfies the file name requirements (but it can be '.').
    is_valid_foldername = @(x) ischarstr(x) && ~isempty(x) && all(ismember(char(x), ['a':'z', 'A':'Z', '0':'9', '_', '-']));
    if ~ischarstr(profile_options.(ProfileOptionKey.BENCHMARK_ID.value)) || ~is_valid_foldername(profile_options.(ProfileOptionKey.BENCHMARK_ID.value)) && ~strcmp(profile_options.(ProfileOptionKey.BENCHMARK_ID.value), '.')
        error("MATLAB:benchmark:benchmark_idNotValid", "profile_options.benchmark_id should be a char or a string satisfying the file name requirements.");
    end
    % Judge whether profile_options.range_type is among 'minmax' and 'meanstd'.
    if ~ischarstr(ProfileOptionKey.RANGE_TYPE.value) || ~ismember(char(profile_options.(ProfileOptionKey.RANGE_TYPE.value)), {'minmax', 'meanstd'})
        error("MATLAB:benchmark:range_typeNotValid", "range_type should be either 'minmax' or 'meanstd'.");
    end
    % Judge whether profile_options.std_factor is a positive real number.
    if ~isrealscalar(profile_options.(ProfileOptionKey.STD_FACTOR.value)) || profile_options.(ProfileOptionKey.STD_FACTOR.value) <= 0
        error("MATLAB:benchmark:std_factorNotValid", "std_factor should be a positive real number.");
    end
    % Judge whether profile_options.savepath is a string and exists. If not exists, create it.
    if ~ischarstr(profile_options.(ProfileOptionKey.SAVEPATH.value))
        error("MATLAB:benchmark:savepathNotValid", "savepath should be a char or a string.");
    elseif ~exist(profile_options.(ProfileOptionKey.SAVEPATH.value), 'dir')
        status = mkdir(profile_options.(ProfileOptionKey.SAVEPATH.value));
        if ~status
            error("MATLAB:benchmark:savepathNotExist", "profile_options.savepath does not exist and cannot be created.");
        end
    end
    % Judge whether profile_options.max_tol_order is a positive integer.
    if ~isintegerscalar(profile_options.(ProfileOptionKey.MAX_TOL_ORDER.value)) || profile_options.(ProfileOptionKey.MAX_TOL_ORDER.value) <= 0
        error("MATLAB:benchmark:max_tol_orderNotValid", "max_tol_order should be a positive integer.");
    end
    % Judge whether profile_options.max_eval_factor is a positive integer.
    if ~isintegerscalar(profile_options.(ProfileOptionKey.MAX_EVAL_FACTOR.value)) || profile_options.(ProfileOptionKey.MAX_EVAL_FACTOR.value) <= 0
        error("MATLAB:benchmark:max_eval_factorNotValid", "max_eval_factor should be a positive integer.");
    end
    % Judge whether profile_options.project_x0 is a boolean.
    if ~islogicalscalar(profile_options.(ProfileOptionKey.PROJECT_X0.value))
        error("MATLAB:benchmark:project_x0NotValid", "project_x0 should be a boolean.");
    end
    % Judge whether profile_options.run_plain is a boolean.
    if ~islogicalscalar(profile_options.(ProfileOptionKey.RUN_PLAIN.value))
        error("MATLAB:benchmark:run_plainNotValid", "run_plain should be a boolean.");
    end
    % Judge whether profile_options.summarize_performance_profiles is a boolean.
    if ~islogicalscalar(profile_options.(ProfileOptionKey.SUMMARIZE_PERFORMANCE_PROFILES.value))
        error("MATLAB:benchmark:summarize_performance_profilesNotValid", "summarize_performance_profiles should be a boolean.");
    end
    % Judge whether profile_options.summarize_data_profiles is a boolean.
    if ~islogicalscalar(profile_options.(ProfileOptionKey.SUMMARIZE_DATA_PROFILES.value))
        error("MATLAB:benchmark:summarize_data_profilesNotValid", "summarize_data_profiles should be a boolean.");
    end
    % Judge whether profile_options.summarize_log_ratio_profiles is a boolean.
    if ~islogicalscalar(profile_options.(ProfileOptionKey.SUMMARIZE_LOG_RATIO_PROFILES.value))
        error("MATLAB:benchmark:summarize_log_ratio_profilesNotValid", "summarize_log_ratio_profiles should be a boolean.");
    end
    if profile_options.(ProfileOptionKey.SUMMARIZE_LOG_RATIO_PROFILES.value) && numel(solvers) > 2
        warning("MATLAB:benchmark:summarize_log_ratio_profilesOnlyWhenTwoSolvers", "The log-ratio profiles are available only when there are exactly two solvers.");
        profile_options.(ProfileOptionKey.SUMMARIZE_LOG_RATIO_PROFILES.value) = false;
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Use cutest_options to select problems. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Select the problems based on cutest_options.
    cutest_problem_names_options = selector(cutest_options);

    % Preprocess the CUTEst problem names given by the user.
    if ~isempty(cutest_problem_names)
        if ~ischarstr(cutest_problem_names) && ~(iscell(cutest_problem_names) && all(cellfun(@ischarstr, cutest_problem_names)))
            error("MATLAB:benchmark:cutest_problem_namesNotValid", "The CUTEst problem names must be a charstr or a cell array of charstr.");
        end
        if ischarstr(cutest_problem_names)
            cutest_problem_names = {cutest_problem_names};
        end
        % Convert to a cell row vector of upper case chars.
        cutest_problem_names = cellfun(@char, cutest_problem_names, 'UniformOutput', false);
        cutest_problem_names = cellfun(@upper, cutest_problem_names, 'UniformOutput', false);
        cutest_problem_names = cutest_problem_names(:)';
    end

    % Merge the problem names selected by cutest_options and given by the user.
    % N.B.: Duplicate names are and MUST BE removed.
    if isempty(cutest_problem_names)
        cutest_problem_names = cutest_problem_names_options;
    elseif ~isempty(fieldnames(cutest_options))
        cutest_problem_names = unique(cutest_problem_names);
    else
        cutest_problem_names = unique([cutest_problem_names, cutest_problem_names_options]);
    end

    % Exclude the problems specified by cutest_options.excludelist.
    if isfield(cutest_options, CutestOptionKey.EXCLUDELIST.value) && ~isempty(cutest_options.(CutestOptionKey.EXCLUDELIST.value))
        cutest_problem_names = setdiff(cutest_problem_names, cutest_options.(CutestOptionKey.EXCLUDELIST.value));
    end

    % Check whether the total number of problems is zero.
    if isempty(cutest_problem_names) && isempty(custom_problem_names)
        error("MATLAB:benchmark:AtLeastOneProblem", "At least one problem must be given.");
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Set the default values for plotting. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Paths to the results.
    timestamp = datestr(datetime('now', 'TimeZone', 'local', 'Format', 'yyyy-MM-dd''T''HH-mm-SSZ'), 'yyyy-mm-ddTHH-MM-SSZ');
    path_out = fullfile(profile_options.(ProfileOptionKey.SAVEPATH.value), 'out', profile_options.(ProfileOptionKey.BENCHMARK_ID.value));
    if ~exist(path_out, 'dir')
        mkdir(path_out);
    end

    % If the path does not exist or it is an empty directory, create it and store the timestamp, otherwise, append the timestamp.
    contents = dir(path_out);
    is_empty = isempty(contents) || (length(contents) == 2 && all(cellfun(@(x) ismember(x, {'.', '..'}), {contents.name})));

    if is_empty
        % Try to save the timestamp for later reference.
        try
            fid = fopen(fullfile(path_out, 'timestamp.txt'), 'w');
            fprintf(fid, timestamp);
            fclose(fid);
        catch
            fprintf("WARNING: The timestamp could not be saved.\n");
        end
    else
        % Check whether all the subdirectories are named by timestamps or 'time-unknown', 'time-unknown-2', 'time-unknown-3', ...
        timestamp_pattern = '^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}Z$';
        unknown_pattern = '^time-unknown(-\d+)?$';
        fullpattern = ['(' timestamp_pattern ')|(' unknown_pattern ')'];
        filtered_contents = contents(~startsWith({contents.name}, '.'));
        is_all_timestamps = all(arrayfun(@(x) x.isdir && ~isempty(regexp(x.name, fullpattern, 'once')), filtered_contents));
        if ~is_all_timestamps
            % Initialize the name of the directory by 'time-unknown'. If there are multiple directories named by 'time-unknown' or 'time-unknown-2', 'time-unknown-3', ..., use the next number.
            unknown_dirs = filtered_contents(contains({filtered_contents.name}, 'time-unknown'));
            if isempty(unknown_dirs)
                old_timestamp = 'time-unknown';
            else
                last_unknown_dir = unknown_dirs(end);
                last_unknown_dir_name = last_unknown_dir.name;
                if strcmp(last_unknown_dir_name, 'time-unknown')
                    old_timestamp = 'time-unknown-2';
                else
                    num_str = regexp(last_unknown_dir_name, '\d+$', 'match');
                    if isempty(num_str)
                        old_timestamp = 'time-unknown-2';
                    else
                        last_unknown_number = str2double(num_str{1});
                        old_timestamp = ['time-unknown-' num2str(last_unknown_number + 1)];
                    end
                end
            end
            % Try to find 'timestamp.txt' and read the timestamp.
            for i = 1:length(filtered_contents)
                if strcmp(filtered_contents(i).name, 'timestamp.txt')
                    try
                        fid = fopen(fullfile(path_out, 'timestamp.txt'), 'r');
                        old_timestamp_new = fscanf(fid, '%s');
                        fclose(fid);
                    catch
                    end
                    break;
                end
            end
            try
                mkdir(fullfile(path_out, old_timestamp_new));
                old_timestamp = old_timestamp_new;
            catch
                mkdir(fullfile(path_out, old_timestamp));
            end
            % Move all the filtered contents that does not match the fullpattern to the new directory.
            for i_item = 1:length(filtered_contents)
                item = filtered_contents(i_item);
                if isempty(regexp(item.name, fullpattern, 'once'))
                    movefile(fullfile(path_out, item.name), fullfile(path_out, old_timestamp, item.name));
                end
            end
        end
        path_out = fullfile(path_out, timestamp);
    end
    
    if ~exist(path_out, 'dir')
        mkdir(path_out);
    end

    % Set the default values for plotting.
    set(groot, 'DefaultLineLineWidth', 1);
    set(groot, 'DefaultAxesFontSize', 12);
    set(groot, 'DefaultAxesFontName', 'Arial');

    if strcmp(feature_names, 'all')
        feature_names = cellfun(@(x) x.value, num2cell(enumeration('FeatureName')), 'UniformOutput', false);
        custom_idx = strcmp(feature_names, FeatureName.CUSTOM.value);
        feature_names(custom_idx) = [];
    elseif ischarstr(feature_names)
        feature_names = {feature_names};
    end

    if length(feature_names) > 1 && numel(fieldnames(feature_options)) > 0
        error("MATLAB:benchmark:OnlyOneFeatureWhenHavingfeature_options", "Only one feature can be specified when feature options are given.");
    end

    for i_feature = 1:length(feature_names)
        feature_name = feature_names{i_feature};

        %TODO: deal with feature_options

        % Build feature.
        feature = Feature(feature_name, feature_options);
        fprintf('INFO: Starting the computation of the "%s" profiles.\n', feature.name);

        % Solve all the problems.
        [fun_histories, maxcv_histories, fun_out, maxcv_out, fun_init, maxcv_init, n_eval, problem_names, problem_dimensions, time_processes] = solveAllProblems(cutest_problem_names, custom_problem_loader, custom_problem_names, solvers, labels, feature, profile_options);
        merit_histories = computeMeritValues(fun_histories, maxcv_histories, maxcv_init);
        merit_out = computeMeritValues(fun_out, maxcv_out, maxcv_init);
        merit_init = computeMeritValues(fun_init, maxcv_init, maxcv_init);

        % Determine the least merit value for each problem.
        merit_min = min(min(min(merit_histories, [], 4, 'omitnan'), [], 3, 'omitnan'), [], 2, 'omitnan');
        if feature.isStochastic && profile_options.(ProfileOptionKey.RUN_PLAIN.value)
            feature_plain = Feature(FeatureName.PLAIN.value);
            fprintf('INFO: Starting the computation of the "plain" profiles.\n');
            [fun_histories_plain, maxcv_histories_plain, ~, ~, ~, ~, ~, ~, ~, time_processes_plain] = solveAllProblems(cutest_problem_names, custom_problem_loader, custom_problem_names, solvers, labels, feature_plain, profile_options);
            time_processes = time_processes + time_processes_plain;
            merit_histories_plain = computeMeritValues(fun_histories_plain, maxcv_histories_plain, maxcv_init);
            merit_min_plain = min(min(min(merit_histories_plain, [], 4, 'omitnan'), [], 3, 'omitnan'), [], 2, 'omitnan');
            merit_min = min(merit_min, merit_min_plain, 'omitnan');
        end

        % Paths to the results of the feature.
        path_feature = fullfile(path_out, feature.name);
        path_perf = fullfile(path_feature, 'figures', 'perf');
        path_data = fullfile(path_feature, 'figures', 'data');
        path_log_ratio = fullfile(path_feature, 'figures', 'log-ratio');
        path_perf_hist = fullfile(path_perf, 'history-based');
        path_data_hist = fullfile(path_data, 'history-based');
        path_log_ratio_hist = fullfile(path_log_ratio, 'history-based');
        path_perf_out = fullfile(path_perf, 'output-based');
        path_data_out = fullfile(path_data, 'output-based');
        path_log_ratio_out = fullfile(path_log_ratio, 'output-based');
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
        fclose(fid);

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
        pdf_summary = fullfile(path_out, 'summary.pdf');
        pdf_perf_hist_summary = fullfile(path_perf, 'perf_hist.pdf');
        pdf_perf_out_summary = fullfile(path_perf, 'perf_out.pdf');
        pdf_data_hist_summary = fullfile(path_data, 'data_hist.pdf');
        pdf_data_out_summary = fullfile(path_data, 'data_out.pdf');
        pdf_log_ratio_hist_summary = fullfile(path_log_ratio, 'log-ratio_hist.pdf');
        pdf_log_ratio_out_summary = fullfile(path_log_ratio, 'log-ratio_out.pdf');

        % Create the figure for the summary.
        warning('off');
        n_rows = 0;
        is_perf = profile_options.(ProfileOptionKey.SUMMARIZE_PERFORMANCE_PROFILES.value);
        is_data = profile_options.(ProfileOptionKey.SUMMARIZE_DATA_PROFILES.value);
        is_log_ratio = profile_options.(ProfileOptionKey.SUMMARIZE_LOG_RATIO_PROFILES.value) && (n_solvers <= 2);
        if is_perf
            n_rows = n_rows + 1;
        end
        if is_data
            n_rows = n_rows + 1;
        end
        if is_log_ratio
            n_rows = n_rows + 1;
        end
        defaultFigurePosition = get(0, 'DefaultFigurePosition');
        default_width = defaultFigurePosition(3);
        default_height = defaultFigurePosition(4);
        fig_summary = figure('Position', [defaultFigurePosition(1:2), profile_options.(ProfileOptionKey.MAX_TOL_ORDER.value) * default_width, 2 * n_rows * default_height], 'visible', 'off');
        T_summary = tiledlayout(fig_summary, 2, 1, 'Padding', 'compact', 'TileSpacing', 'compact');
        T_title = strrep(feature.name, '_', '\_');
        title(T_summary, ['Profiles with the ``', T_title, '" feature'], 'Interpreter', 'latex', 'FontSize', 24);
        % Use gobjects to create arrays of handles and axes.
        t_summary = gobjects(2, 1);
        axs_summary = gobjects([2, 1, n_rows, profile_options.(ProfileOptionKey.MAX_TOL_ORDER.value)]);
        i_axs = 0;
        for i = 1:2
            t_summary(i) = tiledlayout(T_summary, n_rows, profile_options.(ProfileOptionKey.MAX_TOL_ORDER.value), 'Padding', 'compact', 'TileSpacing', 'compact');
            t_summary(i).Layout.Tile = i;
            for j = 1:n_rows * profile_options.(ProfileOptionKey.MAX_TOL_ORDER.value)
                i_axs = i_axs + 1;
                axs_summary(i_axs) = nexttile(t_summary(i));
            end
        end
        ylabel(t_summary(1), "History-based profiles", 'Interpreter', 'latex', 'FontSize', 20);
        ylabel(t_summary(2), "Output-based profiles", 'Interpreter', 'latex', 'FontSize', 20);

        for i_profile = 1:profile_options.(ProfileOptionKey.MAX_TOL_ORDER.value)
            tolerance = tolerances(i_profile);
            [tolerance_str, tolerance_latex] = formatFloatScientificLatex(tolerance);
            fprintf("Creating profiles for tolerance %s.\n", tolerance_str);
            tolerance_label = ['$\mathrm{tol} = ' tolerance_latex '$'];

            work_hist = NaN(n_problems, n_solvers, n_runs);
            work_out = NaN(n_problems, n_solvers, n_runs);
            for i_problem = 1:n_problems
                for i_solver = 1:n_solvers
                    for i_run = 1:n_runs
                        if isfinite(merit_min(i_problem))
                            threshold = max(tolerance * merit_init(i_problem) + (1 - tolerance) * merit_min(i_problem), merit_min(i_problem));
                        else
                            threshold = -Inf;
                        end
                        if min(merit_histories(i_problem, i_solver, i_run, :), [], 'omitnan') <= threshold
                            work_hist(i_problem, i_solver, i_run) = find(merit_histories(i_problem, i_solver, i_run, :) <= threshold, 1, 'first');
                        end
                        if merit_out(i_problem, i_solver, i_run) <= threshold
                            work_out(i_problem, i_solver, i_run) = n_eval(i_problem, i_solver, i_run);
                        end
                    end
                end
            end

            % Draw the profiles.

            if is_perf && is_data && is_log_ratio
                cell_axs_summary = {axs_summary(i_profile), axs_summary(i_profile + 3 * max_tol_order), axs_summary(i_profile + max_tol_order), axs_summary(i_profile + 4 * max_tol_order), axs_summary(i_profile + 2 * max_tol_order), axs_summary(i_profile + 5 * max_tol_order)};
            elseif (is_perf && is_data) || (is_perf && is_log_ratio) || (is_data && is_log_ratio)
                cell_axs_summary = {axs_summary(i_profile), axs_summary(i_profile + 2 * max_tol_order), axs_summary(i_profile + max_tol_order), axs_summary(i_profile + 3 * max_tol_order)};
            elseif is_perf || is_data || is_log_ratio
                cell_axs_summary = {axs_summary(i_profile), axs_summary(i_profile + max_tol_order)};
            end

            [fig_perf_hist, fig_perf_out, fig_data_hist, fig_data_out, fig_log_ratio_hist, fig_log_ratio_out] = drawProfiles(work_hist, work_out, problem_dimensions, labels, tolerance_label, cell_axs_summary, is_perf, is_data, is_log_ratio, profile_options);
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

        if i_feature == 1
            exportgraphics(fig_summary, pdf_summary, 'ContentType', 'vector');
        else
            exportgraphics(fig_summary, pdf_summary, 'ContentType', 'vector', 'Append', true);
        end
        fprintf('Detailed results stored in %s\n', path_feature);

        warning('on');

    end

    % Close the figures.
    close(fig_summary);
    fprintf('Summary stored in %s\n', path_out);

end


function merit_values = computeMeritValues(fun_values, maxcv_values, maxcv_init)
    copied_dim = size(fun_values);
    maxcv_init = repmat(maxcv_init, [1, copied_dim(2:end)]);
    infeasibility_thresholds = max(1e-5, maxcv_init);
    is_infeasible = maxcv_values > infeasibility_thresholds;
    is_almost_feasible = (1e-10 < maxcv_values) & (maxcv_values <= infeasibility_thresholds);
    merit_values = fun_values;
    merit_values(is_infeasible | isnan(merit_values)) = Inf;
    merit_values(is_almost_feasible) = merit_values(is_almost_feasible) + 1e5 * maxcv_values(is_almost_feasible);
end