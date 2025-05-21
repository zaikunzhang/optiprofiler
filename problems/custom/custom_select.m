function problem_names = custom_select(options)
    % This is a toy example to show how to write a custom problem selector.
    % We will use the mat file `custom_info.mat` created by
    % `custom_getInfo` to select the problems.

    % Initialization.
    problem_names = {};

    % Set default values for options.
    if ~isfield(options, 'ptype')
        options.ptype = 'ubln';
    end
    if ~isfield(options, 'mindim')
        options.mindim = 1;
    end
    if ~isfield(options, 'maxdim')
        options.maxdim = Inf;
    end
    if ~isfield(options, 'minb')
        options.minb = 0;
    end
    if ~isfield(options, 'maxb')
        options.maxb = Inf;
    end
    if ~isfield(options, 'minlcon')
        options.minlcon = 0;
    end
    if ~isfield(options, 'maxlcon')
        options.maxlcon = Inf;
    end
    if ~isfield(options, 'minnlcon')
        options.minnlcon = 0;
    end
    if ~isfield(options, 'maxnlcon')
        options.maxnlcon = Inf;
    end
    if ~isfield(options, 'mincon')
        options.mincon = 0;
    end
    if ~isfield(options, 'maxcon')
        options.maxcon = Inf;
    end
    if ~isfield(options, 'excludelist')
        options.excludelist = {};
    end

    % Load the data from a .mat file.
    load('custom_info.mat', 'probinfo');

    % Loop through each problem and check the criteria.
    for i_problem = 2:size(probinfo, 1)
        problem_name = probinfo{i_problem, 1};
        ptype = probinfo{i_problem, 2};
        dim = probinfo{i_problem, 3};
        mb = probinfo{i_problem, 4};
        mlcon = probinfo{i_problem, 5};
        mnlcon = probinfo{i_problem, 6};
        mcon = probinfo{i_problem, 7};

        % Check the criteria.
        if ismember(ptype, options.ptype) && ...
           (dim >= options.mindim && dim <= options.maxdim) && ...
           (mb >= options.minb && mb <= options.maxb) && ...
           (mlcon >= options.minlcon && mlcon <= options.maxlcon) && ...
           (mnlcon >= options.minnlcon && mnlcon <= options.maxnlcon) && ...
           (mcon >= options.mincon && mcon <= options.maxcon) && ...
           ~ismember(problem_name, options.excludelist)
            problem_names{end + 1} = problem_name;
        end
    end
end