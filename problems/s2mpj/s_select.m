function [problem_names, argins] = s_select(options)
%S_SELECT specific problem selector for the problem set "S2MPJ".

    % Initialization.
    problem_names = {};
    argins = {};

    % Check whether the options are valid.
    valid_fields = {'p_type', 'p_type', 'mindim', 'maxdim', 'mincon', 'maxcon', 'oracle', 'excludelist'};
    if ~isstruct(options) || (~isempty(fieldnames(options)) && ~all(ismember(fieldnames(options), valid_fields)))
        error('The input argument `options` is invalid.');
    end

    % Set default values for options.
    if ~isfield(options, 'p_type')
        options.p_type = 'ubln';
    end
    if ~isfield(options, 'mindim')
        options.mindim = 1;
    end
    if ~isfield(options, 'maxdim')
        options.maxdim = Inf;
    end
    if ~isfield(options, 'mincon')
        options.mincon = 0;
    end
    if ~isfield(options, 'maxcon')
        options.maxcon = Inf;
    end
    if ~isfield(options, 'oracle')
        options.oracle = 0;
    end
    if ~isfield(options, 'excludelist')
        options.excludelist = {};
    end

    % Load the data from a .mat file.
    load('probinfo.mat', 'probinfo');

    for i_problem = 2:size(probinfo, 1)
        problem_name = probinfo{i_problem, 1};
        p_type = probinfo{i_problem, 2};
        dim = probinfo{i_problem, 4};
        m_con = probinfo{i_problem, 8};
        argin = probinfo{i_problem, 25};
        dims = probinfo{i_problem, 26};
        m_cons = probinfo{i_problem, 30};

        % If the oracle is not 0, then we exclude problem 'NOZZLEfp' since it does not have first- or second-order information.
        % "NOZZLEfp" is designed to simulate jet impingement cooling.
        % See https://optimization-online.org/wp-content/uploads/2024/03/Design_Optimization_Of_A_Jet_Plate_for_Impingement_Cooling-1.pdf
        if options.oracle ~= 0
            options.excludelist = [options.excludelist, 'NOZZLEfp'];
        end

        % Check if the problem is in the exclude list.
        if ~isempty(options.excludelist) && ismember(problem_name, options.excludelist)
            continue;
        end

        % Check if the problem type satisfies the criteria.
        if ~ismember(p_type, options.p_type)
            continue;
        end

        % If the default dimension and number of constraints satisfy the criteria, we add the problem.
        % That means, we will not consider the changeable dimension and number of constraints if the
        % default dimension and number of constraints satisfy the criteria.
        if dim >= options.mindim && dim <= options.maxdim && m_con >= options.mincon && m_con <= options.maxcon
            problem_names{end + 1} = problem_name;
            argins{end + 1} = {};
            continue;
        end

        % If the default dimension and number of constraints do not satisfy the criteria, we consider
        % the changeable dimension and number of constraints.
        if ~isempty(dims) && any(dims >= options.mindim & dims <= options.maxdim) && any(m_cons >= options.mincon & m_cons <= options.maxcon)
            idx = find(dims >= options.mindim & dims <= options.maxdim, 1, 'first');
            if m_cons(idx) == 0
                problem_names{end + 1} = [problem_name, '_', num2str(dims(idx))];
            else
                problem_names{end + 1} = [problem_name, '_', num2str(dims(idx)), '_', num2str(m_cons(idx))];
            end
            if iscell(argin)
                argins{end + 1} = {argin{1:end-1}, argin{end}(idx)};
            else
                argins{end + 1} = argin(idx);
            end
        end
        
    end
end