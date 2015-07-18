classdef InputModel_i_step < InputModel
  %InputModel_i_step Step input current
  %   Parameters to set in NeuronParams.Input:
  %   - amplitude, the step current amplitude (in pA). This can either be a
  %   single value for all the neurons in the group, or an array of length
  %   equal to the number of neurons in the group, specifying the
  %   amplitude per neuron.
  %   - timeOn, the simulation time (in ms) to turn the current on.
  %   - timeOff, the simulation time (in ms) to turn the current off.
  %
  %   Optional parameters to set in NeuronParams.Input:
  %   - compartmentsInput, which compartments of the neurons the current
  %   should be applied to. If not specified, the current is applied to
  %   all compartments. For standard somatic current injection,
  %   compartmentsInput should be set to 1.
  %   
  %   The current is weighted by compartment membrane area.
  
  properties (SetAccess = private)
    count
    stepOn
    stepOff
    meanInput
  end
  
  methods
    function IM = InputModel_i_step(N, inputID, number, timeStep, compartmentsInput, subset)
      %narginchk(4, 6)
      if nargin == 4
        compartmentsInput = 1:N.numCompartments;
        subset = 1:number;
      elseif nargin == 5
        subset = 1:number;
      end
      N.Input(inputID).meanInput = N.Input(inputID).amplitude;
      IM = IM@InputModel(N, inputID, number, compartmentsInput, subset);
      IM = setupStepCurrent(IM, N, inputID, timeStep);
    end
    
    function IM = setupStepCurrent(IM, N, inputID, timeStep)
      mi = N.Input(inputID).amplitude(:);
      IM.meanInput = bsxfun(@times, mi, IM.membraneAreaRatio);
      IM.count = 1;
      if N.Input.timeOn <= 0
        IM.stepOn  = 1;
      else
        IM.stepOn  = round(N.Input.timeOn  / timeStep);
      end
      IM.stepOff = round(N.Input.timeOff / timeStep);
      IM.I_input = 0;
    end
    
    function IM = updateInput(IM, ~)
      if IM.count == IM.stepOn
        IM.I_input = IM.meanInput;
      elseif IM.count == IM.stepOff
        IM.I_input = 0;
      end
      IM.count = IM.count + 1;
    end
    
    function I = getRecordingVar(IM)
      I = IM.I_input;
    end
    
  end % methods
  
  methods(Static)
    function params = getRequiredParams()
      params = {'amplitude', 'timeOn', 'timeOff'};
    end
  end
  
end % classdef