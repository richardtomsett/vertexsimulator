classdef NeuronModel_poisson < NeuronModel
  %NeuronModel_poisson Neurons generating Poisson spike trains
  %   Parameters to set in NeuronParams in addition to passive parameters:
  %   - firingRate, the mean firing rate of the neurons (in Hz)
  
  properties (SetAccess = private)
    number
    rate
    spikes
  end
  
  methods
    function NM = NeuronModel_poisson(Neuron, number)
      NM = NM@NeuronModel(Neuron, number);
      NM.v = Neuron.E_leak .* ones(number, Neuron.numCompartments);
      NM.number = number;
      NM.rate = Neuron.firingRate;
      NM.spikes = [];
    end
    
    function [NM] = updateNeurons(NM, IM, N, SM, dt)
      NM = updateNeurons@NeuronModel(NM, IM, N, SM, dt);

      NM.spikes = rand(NM.number, 1) <= dt/1000 * NM.rate ;
    end
    
    function spikes = get.spikes(NM)
      spikes = NM.spikes;
    end
    
  end % methods
  
  methods(Static)
    
    function params = getRequiredParams()
      params = [getRequiredParams@NeuronModel, ...
                {'firingRate'}];
    end
    
  end
end % classdef