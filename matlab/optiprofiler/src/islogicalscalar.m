function isls = islogicalscalar(x)
%ISLOGICALSCALAR checks whether x is a logical scalar, including 0 and 1.
% N.B.: islogicalscalar([]) = FALSE !!!
%
%   Function from: https://github.com/zaikunzhang/prima

    if isa(x, 'logical') && isscalar(x)
        isls = true;
    elseif isrealscalar(x) && (x == 1 || x == 0) % !!!!!!
        isls = true;
    else
        isls = false;
    end
end
