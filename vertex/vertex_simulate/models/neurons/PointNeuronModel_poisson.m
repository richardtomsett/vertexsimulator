classdef PointNeuronModel_poisson < handle
  %PointNeuronModel_poisson Neurons generating Poisson spike trains
  %(single compartment)
  %   Parameters to set in NeuronParams:
  %   - firingRate, the mean firing rate of the neurons (in Hz)
  
  properties (SetAccess = private)
    number
    rate
    spikes
  end
  
  methods
    function NM = PointNeuronModel_poisson(Neuron, number)
      %NM = NM@NeuronModel(Neuron, number);
      NM.number = number;
      NM.rate = Neuron.randomRate;
      NM.spikes = [];
    end
    
    function [NM] = updateNeurons(NM, ~, ~, ~, dt)
      %NM = updateNeurons@NeuronModel(NM, IM, N, SM, dt);
      if NM.rate ~= 0
        NM.spikes = rand(NM.number, 1) <= dt/1000 * NM.rate;
      end
    end
    
    function spikes = get.spikes(NM)
      spikes = NM.spikes;
    end
    
  end % methods
  
  methods(Static)
    
    function params = getRequiredParams()
      params = [getRequiredParams@PointNeuronModel, ...
                {'firingRate'}];
    end
  end
end % classdef