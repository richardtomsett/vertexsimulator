classdef InputModel_g_ou < InputModel
  %InputModel_g_ou Random (Ornstein-Uhlenbeck process) input conductance
  %   Parameters to set in NeuronParams.Input:
  %   - meanInput, the mean conductance value (in nS). This can either be a
  %   single value for all the neurons in the group, or an array of length
  %   equal to the number of neurons in the group, specifying the
  %   meanInput per neuron.
  %   - tau, the autocorrelation time constant (in ms). This can either be a
  %   single value for all the neurons in the group, or an array of length
  %   equal to the number of neurons in the group, specifying the
  %   tau per neuron.
  %   - E_reversal, the reversal potential (in mV). This can either be a
  %   single value for all the neurons in the group, or an array of length
  %   equal to the number of neurons in the group, specifying the
  %   E_reversal per neuron.
  %   - stdInput, the conductance standard deviation (in nS). This can either be a
  %   single value for all the neurons in the group, or an array of length
  %   equal to the number of neurons in the group, specifying a the
  %   stdInput per neuron.
  %
  %   Optional parameters to set in NeuronParams.Input:
  %   - compartments, which compartments of the neurons the conductance
  %   should be applied to. If not specified, the conductance is applied to
  %   all compartments.
  %   
  %   The conductance is weighted by compartment membrane area.
  
  properties (SetAccess = private)
    optInputPars
    g
    E_reversal
  end
  
  methods
    function IM = InputModel_g_ou(N, inputID, number, timeStep, compartmentsInput, subset)
      %checkNumArgs(nargin, 4, 6)
      if nargin == 4
        compartmentsInput = 1:N.numCompartments;
        subset = 1:number;
      elseif nargin == 5
        subset = 1:number;
      end
      IM = IM@InputModel(N, inputID, number, compartmentsInput, subset);
      IM = precalculateOUpars(IM, N, inputID, timeStep, subset);
      IM.g = N.Input(inputID).meanInput .* ones(size(IM.I_input));
      IM.E_reversal = N.Input(inputID).E_reversal;
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
      
%       if N.numCompartments > 1
%         membraneAreaRatio = (N.compartmentLengthArr .* ...
%           N.compartmentDiameterArr) ./ ...
%           sum(N.compartmentLengthArr .* ...
%           N.compartmentDiameterArr);
%       end

      if size(meanInput, 1) > 1
        meanInput = meanInput(subset, :);
      end
      if size(tau, 1) > 1
        tau = tau(subset, :);
      end
      if size(stdInput, 1) > 1
        stdInput = stdInput(subset, :);
      end
      
%       if N.numCompartments == 1
%         IM.optInputPars.meanInput = meanInput;
%       elseif length(meanInput) == length(membraneAreaRatio)
%         IM.optInputPars.meanInput = meanInput;
%       else
%         IM.optInputPars.meanInput = meanInput .* membraneAreaRatio;
%       end
%       
%       if N.numCompartments == 1
%         IM.optInputPars.expMinusLambdaDelta_t = 1 - exp(-timeStep./tau);
%       elseif length(tau) == length(membraneAreaRatio)
%         IM.optInputPars.expMinusLambdaDelta_t = 1 - exp(-timeStep./tau);
%       else
%         IM.optInputPars.expMinusLambdaDelta_t = ...
%           1 - exp(-timeStep ./ (tau .* ones(size(membraneAreaRatio))));
%       end
%       
%       if N.numCompartments == 1
%         IM.optInputPars.dWtconstTimesStd = ...
%           sqrt(1 - exp(-(2*timeStep) ./ tau)) .* stdInput;
%       elseif length(stdInput) == length(membraneAreaRatio)
%         IM.optInputPars.dWtconstTimesStd = ...
%           sqrt(1 - exp(-(2*timeStep) ./ tau)) .* stdInput;
%       else
%         IM.optInputPars.dWtconstTimesStd = ...
%           sqrt(1 - exp(-(2*timeStep)./tau)) .* ...
%           (stdInput.*membraneAreaRatio);
%       end
      IM.optInputPars.meanInput = ...
          bsxfun(@times, meanInput, IM.membraneAreaRatio);
      IM.optInputPars.expMinusLambdaDelta_t = ...
        1 - exp(-timeStep ./ bsxfun(@times, ...
                               tau, ones(size(IM.membraneAreaRatio))));
      IM.optInputPars.dWtconstTimesStd = bsxfun(@times, ...
        sqrt(1 - exp(-(2*timeStep)./tau)), ...
        bsxfun(@times, stdInput, IM.membraneAreaRatio));
      IM.optInputPars.expMinusLambdaDelta_t(1,:)
      IM.optInputPars.dWtconstTimesStd(1,:)
    end
    
    function IM = updateInput(IM, NM)
      IM.g = IM.g + ...
        bsxfun(@plus, ...
        bsxfun( @times, IM.optInputPars.expMinusLambdaDelta_t, ...
        bsxfun(@minus, IM.optInputPars.meanInput, IM.g) ), ...
        bsxfun(@times, ...
        IM.optInputPars.dWtconstTimesStd, randn(size(IM.g, 1),1)));
      
      IM.g(IM.g < 0) = 0;
      IM.I_input = -IM.g.*(NM.v - IM.E_reversal);
    end
    
    function g = getRecordingVar(IM)
      g = IM.g;
    end

  end % methods
  
  methods(Static)
    function params = getRequiredParams()
      params = {'meanInput', 'tau', 'E_reversal', 'stdInput'};
    end
  end
end % classdef
