function cutest_options = getDefaultCutestOptions(cutest_options, other_options)
    
    if ~isfield(cutest_options, CutestOptionKey.EXCLUDELIST.value)
        cutest_options.(CutestOptionKey.EXCLUDELIST.value) = {};
    end
    
    % If the user does not provide the cutest_options (empty struct) and provides cutest_problem_names or custom_problem_names with custom_problem_loader, we will not set the default options.
    if numel(fieldnames(cutest_options)) == 0 && (isfield(other_options, OtherOptionKey.CUTEST_PROBLEM_NAMES.value) || (isfield(other_options, OtherOptionKey.CUSTOM_PROBLEM_NAMES.value) && isfield(other_options, OtherOptionKey.CUSTOM_PROBLEM_LOADER.value)))
        return;
    end
    
    if ~isfield(cutest_options, CutestOptionKey.P_TYPE.value)
        cutest_options.(CutestOptionKey.P_TYPE.value) = 'u';
    end
    if ~isfield(cutest_options, CutestOptionKey.MINDIM.value)
        cutest_options.(CutestOptionKey.MINDIM.value) = 1;
    end
    if ~isfield(cutest_options, CutestOptionKey.MAXDIM.value)
        cutest_options.(CutestOptionKey.MAXDIM.value) = cutest_options.(CutestOptionKey.MINDIM.value) + 1;
    end
    if ~isfield(cutest_options, CutestOptionKey.MINCON.value)
        cutest_options.(CutestOptionKey.MINCON.value) = 0;
    end
    if ~isfield(cutest_options, CutestOptionKey.MAXCON.value)
        cutest_options.(CutestOptionKey.MAXCON.value) = cutest_options.(CutestOptionKey.MINCON.value) + 10;
    end
end