classdef InputModel_i_ou_nonuniform < InputModel
  properties (SetAccess = private)
    optInputPars
    toUpdate
  end
  
  methods
    function IM = InputModel_i_ou_nonuniform(N, inputID, number, timeStep, compartmentsInput, subset)
      %checkNumArgs(nargin, 4, 6)
      if nargin == 4
        compartmentsInput = 1:N.numCompartments;
        subset = 1:number;
      elseif nargin == 5
        subset = 1:number;
      end
      IM = IM@InputModel(N, inputID, number, compartmentsInput, subset); 
      IM = precalculateOUpars(IM, N, inputID, timeStep, subset);
    end
    
    function IM = precalculateOUpars(IM, N, inputID, timeStep, subset)

      meanInput = N.Input(inputID).meanInput;
      tau = N.Input(inputID).tau;
      stdInput = N.Input(inputID).stdInput;
      
      if any(tau <= 0)
        error('vertex:InputModel_ou:initInput', ...
           'tau must be greater than zero');
      end
      if size(tau, 1) ~= size(meanInput, 1)
        error('vertex:InputModel_ou:initInput', ...
           'meanInput & tau must be same size (rows)'); 
      end
      if size(tau, 1) ~= size(meanInput, 1)
        error('vertex:InputModel_ou:initInput', ...
           'stdInput & tau must be same size (rows)'); 
      end
      if ~isequal(size(meanInput), size(stdInput)) || ...
        ~(isvector(meanInput) && isvector(stdInput) && ...
          numel(meanInput) == numel(stdInput))
        error('vertex:InputModel_ou:initInput', ...
           'meanInput & stdInput must be same size'); 
      end
      
      if size(meanInput, 1) > 1
        meanInput = meanInput(subset, :);
      end
      if size(tau, 1) > 1
        tau = tau(subset, :);
      end
      if size(stdInput, 1) > 1
        stdInput = stdInput(subset, :);
      end

      IM.optInputPars.meanInput = ...
          bsxfun(@times, meanInput, IM.membraneAreaRatio);
      IM.optInputPars.expMinusLambdaDelta_t = ...
        1 - exp(-timeStep ./ bsxfun(@times, ...
                               tau, ones(size(IM.membraneAreaRatio))));
      IM.optInputPars.dWtconstTimesStd = bsxfun(@times, ...
        sqrt(1 - exp(-(2*timeStep)./tau)), ...
        bsxfun(@times, stdInput, IM.membraneAreaRatio));
      
      if size(IM.I_input, 2) > 1
        IM.toUpdate = IM.optInputPars.dWtconstTimesStd ~= 0;
      else
        IM.toUpdate = 1;
      end
    end
    
    function IM = updateInput(IM, ~)
      IM.I_input(:, IM.toUpdate) = IM.I_input(:, IM.toUpdate) + ...
        bsxfun(@plus, ...
        bsxfun( @times, IM.optInputPars.expMinusLambdaDelta_t(:, IM.toUpdate), ...
        bsxfun(@minus, IM.optInputPars.meanInput(:, IM.toUpdate), IM.I_input(:, IM.toUpdate)) ), ...
        bsxfun(@times, ...
        IM.optInputPars.dWtconstTimesStd(:, IM.toUpdate), randn(size(IM.I_input, 1),sum(IM.toUpdate))));
      
      IM.I_input(IM.I_input < 0) = 0;
    end
    
    function I = getRecordingVar(IM)
      I = IM.I_input;
    end
    
  end % methods
  
  methods(Static)
    function params = getRequiredParams()
      params = {'meanInput', 'tau', 'stdInput'};
    end
  end
  
end % classdef
