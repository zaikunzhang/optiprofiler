function problem_names = m_select(options)
%M_SELECT selects the problems in MatCUTEst that satisfy given criteria.
%
%   Users only need to use the following signature to call this function:
%
%   PROBLEM_NAMES = M_SELECT(OPTIONS) returns the names of selected problems
%   from MatCUTEst that satisfy the criteria in OPTIONS as a cell array
%   PROBLEM_NAMES.
%
%   OPTIONS is a struct with the following fields:
%
%       - ptype: the type of the problems to be selected. It should be a string
%         or char consisting of any combination of 'u' (unconstrained), 'b'
%         (bound constrained), 'l' (linearly constrained), and 'n' (nonlinearly
%         constrained), such as 'b', 'ul', 'ubn'. Default is 'ubln'.
%       - mindim: the minimum dimension of the problems to be selected. Default
%         is 1.
%       - maxdim: the maximum dimension of the problems to be selected. Default
%         is Inf.
%       - minb: the minimum number of bound constraints of the problems to be
%         selected. Default is 0.
%       - maxb: the maximum number of bound constraints of the problems to be
%         selected. Default is Inf.
%       - mincon: the minimum number of linear and nonlinear constraints of the
%         problems to be selected. Default is 0.
%       - maxcon: the maximum number of linear and nonlinear constraints of the
%         problems to be selected. Default is Inf.
%       - excludelist: the list of problems to be excluded. Default is not to
%         exclude any problem.
%
%   More details about MatCUTEst can be found in the official website:
%
%       https://github.com/matcutest
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Check whether the options are valid.
    valid_fields = {'ptype', 'mindim', 'maxdim', 'minb', 'maxb', 'mincon', 'maxcon', 'excludelist'};
    if ~isstruct(options) || (~isempty(fieldnames(options)) && ~all(ismember(fieldnames(options), valid_fields)))
        error('The input argument `options` is invalid.');
    end

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
    if ~isfield(options, 'mincon')
        options.mincon = 0;
    end
    if ~isfield(options, 'maxcon')
        options.maxcon = Inf;
    end
    if ~isfield(options, 'excludelist')
        options.excludelist = {};
    end

    options.type = options.ptype;
    options = rmfield(options, 'ptype');
    options.blacklist = options.excludelist;
    options = rmfield(options, 'excludelist');

    % Use functions from MatCUTEst to select the problems.
    try
        problem_names = secup(options);
    catch
        error("MATLAB:m_select:errorsecup", "Error occurred while using secup function. Please check if MatCUTEst is installed correctly.");
    end
end