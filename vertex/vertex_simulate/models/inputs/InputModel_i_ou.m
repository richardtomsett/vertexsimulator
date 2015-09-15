classdef InputModel_i_ou < InputModel
  %InputModel_i_ou Random (Ornstein-Uhlenbeck process) input current
  %   Parameters to set in NeuronParams.Input:
  %   - meanInput, the mean current value (in pA). This can either be a
  %   single value for all the neurons in the group, or an array of length
  %   equal to the number of neurons in the group, specifying the
  %   meanInput per neuron.
  %   - tau, the autocorrelation time constant (in ms). This can either be a
  %   single value for all the neurons in the group, or an array of length
  %   equal to the number of neurons in the group, specifying the
  %   tau per neuron.
  %   - stdInput, the current standard deviation (in pA). This can either be a
  %   single value for all the neurons in the group, or an array of length
  %   equal to the number of neurons in the group, specifying the
  %   stdInput per neuron.
  %
  %   Optional parameters to set in NeuronParams.Input:
  %   - compartments, which compartments of the neurons the current
  %   should be applied to. If not specified, the current is applied to
  %   all compartments.
  %   
  %   The current is weighted by compartment membrane area.
  
  properties (SetAccess = private)
    optInputPars
  end
  
  methods
    function IM = InputModel_i_ou(N, inputID, number, timeStep, compartmentsInput, subset)
      %narginchk(4, 6)
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
    end
    
    function IM = updateInput(IM, ~)
      IM.I_input = IM.I_input + ...
        bsxfun(@plus, ...
        bsxfun( @times, IM.optInputPars.expMinusLambdaDelta_t, ...
        bsxfun(@minus, IM.optInputPars.meanInput, IM.I_input) ), ...
        bsxfun(@times, ...
        IM.optInputPars.dWtconstTimesStd, randn(size(IM.I_input, 1),1)));
      
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
