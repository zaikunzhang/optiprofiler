function basic()

    clc

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Example 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    solvers = {@fminsearch_test, @fminunc_test};
    benchmark(solvers)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Example 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % solvers = {@fminsearch_test, @fminunc_test};
    % benchmark(solvers, 'noisy')

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Example 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % solvers = {@fminsearch_test, @fminunc_test};
    % options.feature_name = 'noisy';
    % options.n_runs = 5;
    % options.problem = s_load('LIARWHD');
    % options.seed = 1;
    % benchmark(solvers, options)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Example 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % solvers = {@fminsearch_test, @fminunc_test};
    % options.feature_name = 'noisy';
    % options.n_runs = 5;
    % options.benchmark_id = 'test';
    % options.silent = false;
    % options.keep_pool = true;
    % options.solver_verbose = 1;
    % options.problem_type = 'u';
    % options.maxdim = 5;
    % options.excludelist = {"MUONSINELS"};
    % options.labels = {'simplex', 'bfgs-fd'};
    % benchmark(solvers, options)

end

function x = fminsearch_test(fun, x0)

    options.MaxFunEvals = 3000;
    x = fminsearch(fun, x0, options);
    
end

function x = fminunc_test(fun, x0)

    options.MaxFunEvals = 3000;
    x = fminunc(fun, x0, options);

end