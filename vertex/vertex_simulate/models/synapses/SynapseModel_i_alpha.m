classdef SynapseModel_i_alpha < SynapseModel
  %SynapseModel_i_alpha Current-based alpha synapses
  %   Parameters to set in ConnectionParams:
  %   - tau, the synaptic time constant (in ms)
  
  properties (SetAccess = protected)
    tau
    i_expEventBuffer
    i_aux
    bufferCount
    bufferMax
  end
  
  methods
    function SM = SynapseModel_i_alpha(Neuron, CP, SimulationSettings, ...
                                     postID, number)
      SM = SM@SynapseModel(Neuron, number);
      SM.tau = CP.tau{postID};
      SM.bufferCount = 1;
      maxDelaySteps = SimulationSettings.maxDelaySteps;
      numComparts = Neuron.numCompartments;
      SM.i_expEventBuffer = zeros(number, numComparts, maxDelaySteps);
      SM.i_aux = SM.I_syn;
      SM.bufferMax = maxDelaySteps;

      if SM.tau <= 0
        error('vertex:SynapseModel_i_exp', ...
           'tau must be greater than zero');
      end
    end
    
    function SM = updateBuffer(SM)
      SM.i_aux = SM.i_aux - ...
            SM.i_expEventBuffer(:, :, SM.bufferCount);
          
      SM.i_expEventBuffer(:, :, SM.bufferCount) = 0;
      SM.bufferCount = SM.bufferCount + 1;
      
      if SM.bufferCount > SM.bufferMax
        SM.bufferCount = 1;
      end
    end
    
    function SM = updateSynapses(SM, ~, dt)
      % update synaptic currents
      kg = (SM.i_aux - SM.I_syn) ./ SM.tau;
      kg_aux = - SM.i_aux ./ SM.tau;
      k2g_in = SM.I_syn + 0.5 .* dt .* kg;
      k2g_aux_in = SM.i_aux + 0.5 .* dt .* kg_aux;
      kg = (k2g_aux_in - k2g_in) ./ SM.tau;
      kg_aux = - k2g_aux_in ./ SM.tau;
      SM.I_syn = SM.I_syn + dt .* kg;
      SM.i_aux = SM.i_aux + dt .* kg_aux;
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
