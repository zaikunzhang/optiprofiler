function custom2()

    clc
    
    % Define a custom feature that combines "noisy" and "linearly_transformed".
    
    solvers = {@fminsearch_test, @fminunc_test};
    options.feature_name = 'custom';
    options.n_runs = 10;
    % We need mod_x0 to make sure that the linearly transformed problem is mathematically equivalent
    % to the original problem.
    options.mod_x0 = @mod_x0;
    % We only modify mod_fun since we are dealing with unconstrained problems.
    options.mod_fun = @mod_fun;
    options.mod_affine = @mod_affine;

    benchmark(solvers, options)
end

function x0 = mod_x0(rand_stream, problem)

    [Q, R] = qr(rand_stream.randn(problem.n));
    Q(:, diag(R) < 0) = -Q(:, diag(R) < 0);
    x0 = Q * problem.x0;
end

function f = mod_fun(x, f, rand_stream, problem)

    f = f + max(1, abs(f)) * 1e-3 * rand_stream.randn(1);
end

function [A, b, inv] = mod_affine(rand_stream, problem)

    [Q, R] = qr(rand_stream.randn(problem.n));
    Q(:, diag(R) < 0) = -Q(:, diag(R) < 0);
    A = Q';
    b = zeros(problem.n, 1);
    inv = Q;
end

function x = fminsearch_test(fun, x0)

    x = fminsearch(fun, x0);
    
end

function x = fminunc_test(fun, x0)

    x = fminunc(fun, x0);

end