classdef SynapseModel_g_alpha < SynapseModel
  %SynapseModel_g_alpha Conductance-based alpha synapses
  %   Parameters to set in ConnectionParams:
  %   - E_reversal, the reversal potential (in mV)
  %   - tau, the synaptic decay time constant (in ms)

  properties (SetAccess = protected)
    E_reversal
    tau
    g_alpha
    g_alphaEventBuffer
    g_aux
    bufferCount
    bufferMax
  end
  
  methods
    function SM = SynapseModel_g_alpha(Neuron, CP, SimulationSettings, ...
                                     postID, number)
      SM = SM@SynapseModel(Neuron, number);
      SM.E_reversal = CP.E_reversal{postID};
      SM.tau = CP.tau{postID};
      SM.bufferCount = 1;
      maxDelaySteps = SimulationSettings.maxDelaySteps;
      numComparts = Neuron.numCompartments;
      SM.g_alpha = zeros(number, numComparts);
      SM.g_alphaEventBuffer = zeros(number, numComparts, maxDelaySteps);
      SM.g_aux = SM.g_alpha;
      SM.bufferMax = maxDelaySteps;

      if SM.tau <= 0
        error('vertex:SynapseModel_g_alpha', ...
           'tau must be greater than zero');
      end
    end
    
    function SM = updateBuffer(SM)
      SM.g_aux = SM.g_aux + SM.g_alphaEventBuffer(:, :, SM.bufferCount);
          
      SM.g_alphaEventBuffer(:, :, SM.bufferCount) = 0;
      SM.bufferCount = SM.bufferCount + 1;
      
      if SM.bufferCount > SM.bufferMax
        SM.bufferCount = 1;
      end
    end
    
    function SM = updateSynapses(SM, NM, dt)
      % update synaptic currents
      SM.I_syn = SM.g_alpha .* (NM.v() - SM.E_reversal);
      
      % update synaptic conductances
      kg = (SM.g_aux - SM.g_alpha) ./ SM.tau;
      kg_aux = - SM.g_aux ./ SM.tau;
      k2g_in = SM.g_alpha + 0.5 .* dt .* kg;
      k2g_aux_in = SM.g_aux + 0.5 .* dt .* kg_aux;
      kg = (k2g_aux_in - k2g_in) ./ SM.tau;
      kg_aux = - k2g_aux_in ./ SM.tau;
      SM.g_alpha = SM.g_alpha + dt .* kg;
      SM.g_aux = SM.g_aux + dt .* kg_aux;
    end
    
    function SM = bufferIncomingSpikes(SM, synIndeces, weightsToAdd)
      SM.g_alphaEventBuffer(synIndeces) = ...
                            SM.g_alphaEventBuffer(synIndeces) + weightsToAdd;
    end
    
    function SM = randomInit(SM, g_mean, g_std)
      SM.g_alpha = g_std .* randn(size(SM.g_alpha)) + g_mean;
      SM.g_alpha(SM.g_alpha < 0) = 0;
    end
    
    function g = get.g_alpha(SM)
      g = SM.g_alpha;
    end

  end % methods
  
  
  methods(Static)
    function params = getRequiredParams()
      params = {'tau', 'E_reversal'};
    end
  end
end % classdef
