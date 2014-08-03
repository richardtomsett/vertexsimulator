classdef InputModel < handle
  properties (SetAccess = protected)
    I_input
    membraneAreaRatio
    compartmentsInput
  end
  
  methods
    function IM = InputModel(N, inputID, number, compartmentsInput, subset)
      %narginchk(3, 5)
      if nargin == 3
        subset = 1:number;
        compartmentsInput = 1:N.numCompartments;
      elseif nargin == 4
        subset = 1:number;
      end
      IM.compartmentsInput = compartmentsInput;
      s = size(N.Input(inputID).meanInput);
      c1 = s(1) == 1 && s(2) == 1;
      c2 = s(1) == 1 && s(2) >  1;
      c3 = s(1) >  1 && s(2) == 1;
      c4 = s(1) >  1 && s(2) >  1;
      
      if N.numCompartments > 1
        mAR = (N.compartmentLengthArr(IM.compartmentsInput) .* ...
          N.compartmentDiameterArr(IM.compartmentsInput)) ./ ...
          sum(N.compartmentLengthArr(IM.compartmentsInput) .* ...
          N.compartmentDiameterArr(IM.compartmentsInput));
        IM.membraneAreaRatio = zeros(1, N.numCompartments);
        IM.membraneAreaRatio(IM.compartmentsInput) = mAR;
      else
        IM.membraneAreaRatio = 1;
      end
      
      if c1
        if N.numCompartments > 1
          meanInput = N.Input(inputID).meanInput .* IM.membraneAreaRatio;
        else
          meanInput = N.Input(inputID).meanInput;
        end
        IM.I_input = repmat(meanInput, length(subset), 1);
      elseif c2
        if N.numCompartments > 1
          meanInput = N.Input(inputID).meanInput;
        else
          error('vertex:InputModel:initInput', ...
           'Multiple input values specified for single compartment model');
        end
        IM.I_input = repmat(meanInput, length(subset), 1);
      elseif c3
        if size(N.Input(inputID).meanInput(subset), 1) ~= number
          error('vertex:InputModel:initInput', ...
           'Not enough input current means specified for number in group');
        end
        if N.numCompartments > 1
          meanInput = bsxfun(@times, ...
            N.Input(inputID).meanInput(subset), IM.membraneAreaRatio);
        else
          meanInput = N.Input(inputID).meanInput(subset);
        end
        IM.I_input = meanInput;
      elseif c4
        if size(N.Input(inputID).meanInput(subset), 1) ~= number
          error('vertex:InputModel:initInput', ...
           'Not enough input current means specified for number in group');
        end
        if N.numCompartments > 1
          meanInput = N.Input(inputID).meanInput(subset, :);
        else
          error('vertex:InputModel:initInput', ...
           'Multiple input values specified for single compartment model');
        end
        IM.I_input = meanInput;
      else
        error('vertex:InputModel:initInput', ...
           'Mean input vector has size < 1');
      end
    end
    
    function IM = updateCurrent(IM, ~)
    end
    
    function I_input = get.I_input(IM)
      I_input = IM.I_input;
    end
    
  end % methods
  
  methods(Static)
    function params = getRequiredParams()
      params = {'meanInput'};
    end
  end
end % classdef