function [x, y, ratio_max] = getPerformanceDataProfileAxes(work, denominator, perf_or_data)
%GETPERFORMANCEDATAPROFILEAXES computes the axes for the performance profiles and data profiles.
    [n_problems, n_solvers, n_runs] = size(work);

    % Calculate the x-axis values.
    x = NaN(n_solvers, n_problems, n_runs);
    for i_run = 1:n_runs
        for i_problem = 1:n_problems
            x(:, i_problem, i_run) = work(i_problem, :, i_run) / denominator(i_problem, i_run);
        end
    end

    switch perf_or_data
        case 'perf'
            % Set default ratio_max in the case where all the elements in x is either 1 or NaN.
            if all(x(:) == 1 | isnan(x(:)))
                ratio_max = eps;
            else
                ratio_max = max(log2(x(:)), [], 'omitnan');
            end
        case 'data'
            % Set default ratio_max in the case where all the elements in x is either 0 or NaN.
            if all(x(:) == 0 | isnan(x(:)))
                ratio_max = eps;
            else
                ratio_max = max(x(:), [], 'omitnan');
            end
        otherwise
            error("MATLAB:getPerformanceDataProfileAxes:UnknownNameForgetPerformanceDataProfileAxes", "Unknown perf_or_data.");
    end
    
    x(isnan(x)) = Inf;
    x = sort(x, 2);
    x = reshape(x, [n_solvers, n_problems * n_runs]);
    x = x';
    [x, index_sort_x] = sort(x, 1);
    % Find the index of the element in x(:, i_solver) that is the last element that is less than or equal to ratio_max.
    index_ratio_max = NaN(n_solvers, 1);
    for i_solver = 1:n_solvers
        switch perf_or_data
            case 'perf'
                if ~isempty(find(log2(x(:, i_solver)) <= ratio_max, 1, 'last'))
                    index_ratio_max(i_solver) = find(log2(x(:, i_solver)) <= ratio_max, 1, 'last');
                end
            case 'data'
                if ~isempty(find(x(:, i_solver) <= ratio_max, 1, 'last'))
                    index_ratio_max(i_solver) = find(x(:, i_solver) <= ratio_max, 1, 'last');
                end
        end
    end

    % Calculate the y-axis values.
    y = NaN(n_problems * n_runs, n_solvers, n_runs);
    for i_solver = 1:n_solvers
        for i_run = 1:n_runs
            y((i_run - 1) * n_problems + 1:i_run * n_problems, i_solver, i_run) = linspace(1 / n_problems, 1.0, n_problems);
            y_partial = y(:, i_solver, i_run);
            y(:, i_solver, i_run) = y_partial(index_sort_x(:, i_solver));
            for i_problem = 1:n_problems * n_runs
                if isnan(y(i_problem, i_solver, i_run))
                    if i_problem > 1
                        y(i_problem, i_solver, i_run) = y(i_problem - 1, i_solver, i_run);
                    else
                        y(i_problem, i_solver, i_run) = 0;
                    end
                end
            end
        end
    end

    % Calculate the max_ratio_y, which is the maximum y-value before the corresponding x-value exceeds ratio_max.
    ratio_max_y = zeros(n_solvers, n_runs);
    for i_solver = 1:n_solvers
        for i_run = 1:n_runs
            if ~isnan(index_ratio_max(i_solver))
                ratio_max_y(i_solver, i_run) = y(index_ratio_max(i_solver), i_solver, i_run);
            end
        end
    end

    % Correct the y-values using the ratio_max_y.
    for i_solver = 1:n_solvers
        for i_run = 1:n_runs
            for i_problem = 1:n_problems * n_runs
                y(i_problem, i_solver, i_run) = min(y(i_problem, i_solver, i_run), ratio_max_y(i_solver, i_run));
            end
        end
    end
    
end