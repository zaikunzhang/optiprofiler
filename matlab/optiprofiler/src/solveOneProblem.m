function [fun_histories, maxcv_histories, fun_out, maxcv_out, fun_init, maxcv_init, n_eval, problem_name, problem_n, computation_time] = solveOneProblem(problem_name, solvers, labels, feature, custom_problem_loader, profile_options, is_plot, path_hist_plots)
%SOLVEONEPROBLEM solves one problem with all the solvers in solvers list.

    fun_histories = [];
    maxcv_histories = [];
    fun_out = [];
    maxcv_out = [];
    fun_init = [];
    maxcv_init = [];
    n_eval = [];
    problem_n = [];
    computation_time = [];

    if length(problem_name) == 2
        problem = custom_problem_loader(problem_name{2});

        % Verify whether problem is a Problem object.
        if ~isa(problem, 'Problem')
            if ~profile_options.(ProfileOptionKey.SILENT.value)
                fprintf("Custom problem %s cannot be loaded by custom_problem_loader.\n", problem_name{1});
            end
            return;
        end
        problem_name = sprintf('%s %s', problem_name{1}, problem_name{2});
    else
        try
            problem = loader(problem_name);
        catch
            return;
        end
    end

    problem_n = problem.n;

    % Project the initial point if necessary.
    if profile_options.(ProfileOptionKey.PROJECT_X0.value)
        problem.project_x0;
    end

    % Evaluate the functions at the initial point.
    fun_init = problem.fun(problem.x0);
    maxcv_init = problem.maxcv(problem.x0);

    % Solve the problem with each solver.
    time_start = tic;
    n_solvers = length(solvers);
    n_runs = feature.options.(FeatureOptionKey.N_RUNS.value);
    max_eval = profile_options.(ProfileOptionKey.MAX_EVAL_FACTOR.value) * problem.n;
    n_eval = zeros(n_solvers, n_runs);
    fun_histories = NaN(n_solvers, n_runs, max_eval);
    fun_out = NaN(n_solvers, n_runs);
    maxcv_histories = NaN(n_solvers, n_runs, max_eval);
    maxcv_out = NaN(n_solvers, n_runs);

    for i_solver = 1:n_solvers
        for i_run = 1:n_runs
            if ~profile_options.(ProfileOptionKey.SILENT.value)
                fprintf("Solving %s with %s (run %d/%d).\n", problem_name, labels{i_solver}, i_run, n_runs);
            end
            time_start_solver_run = tic;
            % Construct featured_problem.
            featured_problem = FeaturedProblem(problem, feature, max_eval, i_run);
            warning('off', 'all');
            try
                switch problem.type
                    case 'unconstrained'
                        [~, x] = evalc('solvers{i_solver}(@featured_problem.fun, featured_problem.x0)');
                    case 'bound-constrained'
                        [~, x] = evalc('solvers{i_solver}(@featured_problem.fun, featured_problem.x0, featured_problem.xl, featured_problem.xu)');
                    case 'linearly constrained'
                        [~, x] = evalc('solvers{i_solver}(@featured_problem.fun, featured_problem.x0, featured_problem.xl, featured_problem.xu, featured_problem.aub, featured_problem.bub, featured_problem.aeq, featured_problem.beq)');
                    case 'nonlinearly constrained'
                        [~, x] = evalc('solvers{i_solver}(@featured_problem.fun, featured_problem.x0, featured_problem.xl, featured_problem.xu, featured_problem.aub, featured_problem.bub, featured_problem.aeq, featured_problem.beq, @featured_problem.cub, @featured_problem.ceq)');
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % It is very important to transform the solution back to the original space in the case of permuted and linearly_transformed features!!!
                if strcmp(feature.name, FeatureName.PERMUTED.value)
                    x = x(featured_problem.permutation);
                elseif strcmp(feature.name, FeatureName.LINEARLY_TRANSFORMED.value)
                    x = featured_problem.rotation * (featured_problem.scaler .* x);
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % Use problem.fun and problem.maxcv to evaluate the solution since it is possible that featured_problem.fun and featured_problem.maxcv are modified.
                fun_out(i_solver, i_run) = problem.fun(x);
                maxcv_out(i_solver, i_run) = problem.maxcv(x);
                if ~profile_options.(ProfileOptionKey.SILENT.value)
                    fprintf("Results for %s with %s (run %d/%d): f = %.4e, maxcv = %.4e (%.2f seconds).\n", problem_name, labels{i_solver}, i_run, n_runs, fun_out(i_solver, i_run), maxcv_out(i_solver, i_run), toc(time_start_solver_run));
                end
            catch Exception
                fprintf("An error occurred while solving %s with %s: %s\n", problem_name, labels{i_solver}, Exception.message);
            end
            warning('on', 'all');
            n_eval(i_solver, i_run) = featured_problem.n_eval;
            fun_histories(i_solver, i_run, 1:n_eval(i_solver, i_run)) = featured_problem.fun_hist(1:n_eval(i_solver, i_run));
            maxcv_histories(i_solver, i_run, 1:n_eval(i_solver, i_run)) = featured_problem.maxcv_hist(1:n_eval(i_solver, i_run));
            if n_eval(i_solver, i_run) > 0
                fun_histories(i_solver, i_run, n_eval(i_solver, i_run)+1:end) = fun_histories(i_solver, i_run, n_eval(i_solver, i_run));
                maxcv_histories(i_solver, i_run, n_eval(i_solver, i_run)+1:end) = maxcv_histories(i_solver, i_run, n_eval(i_solver, i_run));
            end
        end
    end
    computation_time = toc(time_start);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% History plots of the computation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if ~is_plot
        return;
    end

    try
        merit_histories = computeMeritValues(fun_histories, maxcv_histories, maxcv_init);
        merit_init = computeMeritValues(fun_init, maxcv_init, maxcv_init);

        % Create the figure for the summary.
        warning('off');
        if strcmp(problem.type, 'unconstrained')
            n_cols = 1;
        else
            n_cols = 3;
        end
        defaultFigurePosition = get(0, 'DefaultFigurePosition');
        default_width = defaultFigurePosition(3);
        default_height = defaultFigurePosition(4);
        fig_summary = figure('Position', [defaultFigurePosition(1:2), n_cols * default_width, 2 * default_height], ...
        'visible', 'off');
        T_summary = tiledlayout(fig_summary, 2, 1, 'Padding', 'compact', 'TileSpacing', 'compact');
        T_title = strrep(feature.name, '_', '\_');
        P_title = strrep(problem_name, '_', '\_');
        title(T_summary, ['Solving ``', P_title, '" with ``', T_title, '" feature'], 'Interpreter', 'latex', ...
        'FontSize', 14);
        % Use gobjects to create arrays of handles and axes.
        t_summary = gobjects(2, 1);
        axs_summary = gobjects([2, 1, 1, n_cols]);
        i_axs = 0;
        for i = 1:2
            t_summary(i) = tiledlayout(T_summary, 1, n_cols, 'Padding', 'compact', 'TileSpacing', 'compact');
            t_summary(i).Layout.Tile = i;
            for j = 1:n_cols
                i_axs = i_axs + 1;
                axs_summary(i_axs) = nexttile(t_summary(i));
            end
        end
        ylabel(t_summary(1), "History profiles", 'Interpreter', 'latex', 'FontSize', 14);
        ylabel(t_summary(2), "Cummin history profiles", 'Interpreter', 'latex', 'FontSize', 14);

        if strcmp(problem.type, 'unconstrained')
            cell_axs_summary = {axs_summary(1)};
            cell_axs_summary_cum = {axs_summary(2)};
        else
            cell_axs_summary = {axs_summary(1), axs_summary(2), axs_summary(3)};
            cell_axs_summary_cum = {axs_summary(4), axs_summary(5), axs_summary(6)};
        end

        hist_file_name = [regexprep(regexprep(regexprep(strrep(problem_name,' ','_'),'[^a-zA-Z0-9\-_]',''),'[-_]+','_'),'^[-_]+',''), '.pdf'];
        pdf_summary = fullfile(path_hist_plots, hist_file_name);
        processed_labels = cellfun(@(s) strrep(s, '_', '\_'), labels, 'UniformOutput', false);

        drawHist(fun_histories, maxcv_histories, merit_histories, fun_init, maxcv_init, merit_init, processed_labels, cell_axs_summary, false, profile_options, problem.type, problem_n);
        drawHist(fun_histories, maxcv_histories, merit_histories, fun_init, maxcv_init, merit_init, processed_labels, cell_axs_summary_cum, true, profile_options, problem.type, problem_n);

        exportgraphics(fig_summary, pdf_summary, 'ContentType', 'vector');
        warning('on');
        close(fig_summary);
    catch Exception
        fprintf("An error occurred while plotting the history plots of the problem %s: %s\n", problem_name, Exception.message);
    end


end