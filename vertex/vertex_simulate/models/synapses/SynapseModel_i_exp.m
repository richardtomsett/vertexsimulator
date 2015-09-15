classdef SynapseModel_i_exp < SynapseModel
  %SynapseModel_i_exp Current-based single exponential synapses
  %   Parameters to set in ConnectionParams:
  %   - tau, the synaptic decay time constant (in ms)
  
  properties (SetAccess = protected)
    tau
    i_expEventBuffer
    bufferCount
    bufferMax
  end
  
  methods
    function SM = SynapseModel_i_exp(Neuron, CP, SimulationSettings, ...
                                     postID, number)
      SM = SM@SynapseModel(Neuron, number);
      SM.tau = CP.tau{postID};
      SM.bufferCount = 1;
      maxDelaySteps = SimulationSettings.maxDelaySteps;
      numComparts = Neuron.numCompartments;
      SM.i_expEventBuffer = zeros(number, numComparts, maxDelaySteps);
      SM.bufferMax = maxDelaySteps;

      if SM.tau <= 0
        error('vertex:SynapseModel_i_exp', ...
           'tau must be greater than zero');
      end
    end
    
    function SM = updateBuffer(SM)
      SM.I_syn = SM.I_syn - ...
            SM.i_expEventBuffer(:, :, SM.bufferCount);
          
      SM.i_expEventBuffer(:, :, SM.bufferCount) = 0;
      SM.bufferCount = SM.bufferCount + 1;
      
      if SM.bufferCount > SM.bufferMax
        SM.bufferCount = 1;
      end
    end
    
    function SM = updateSynapses(SM, ~, dt)
      % update synaptic currents
      kg = - SM.I_syn ./ SM.tau;
      k2g_in = SM.I_syn + 0.5 .* dt .* kg;
      kg = - k2g_in ./ SM.tau;
      SM.I_syn = SM.I_syn + dt .* kg;
    end
    
    function SM = bufferIncomingSpikes(SM, synIndeces, weightsToAdd)
%       if size(SM.i_expEventBuffer(synIndeces), 1) ~= size(weightsToAdd, 1)
%         weightsToAdd = weightsToAdd';
%       end
      SM.i_expEventBuffer(synIndeces) = ...
                            SM.i_expEventBuffer(synIndeces) + weightsToAdd;
    end
    
    function SM = randomInit(SM, i_mean, i_std)
      SM.I_syn = i_std .* randn(size(SM.I_syn)) + i_mean;
      SM.I_syn(SM.I_syn < 0) = 0;
    end

  end % methods
  
  
  methods(Static)
    function params = getRequiredParams()
      params = {'tau'};
    end
  end
end % classdef
