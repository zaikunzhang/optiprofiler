classdef FeatureName
%FEATURENAME enumerates all the possible feature names.
    
    enumeration
        PLAIN ('plain')
        PERTURBED_X0 ('perturbed_x0')
        NOISY ('noisy')
        TRUNCATED ('truncated')
        PERMUTED ('permuted')
        LINEARLY_TRANSFORMED ('linearly_transformed')
        RANDOM_NAN ('random_nan')
        UNRELAXABLE_CONSTRAINTS ('unrelaxable_constraints')
        NONQUANTIFIABLE_CONSTRAINTS ('nonquantifiable_constraints')
        QUANTIZED ('quantized')
        CUSTOM ('custom')
    end
    properties
        value
    end
    methods
        function obj = FeatureName(inputValue)
            obj.value = inputValue;
        end
    end
end