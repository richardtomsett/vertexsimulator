classdef NeuronModel_passive < NeuronModel
  %NeuronModel_passive Purely passive neurons. No additional parameters.
  properties (SetAccess = private)
    number
    spikes
  end
  
  methods
    function NM = NeuronModel_passive(Neuron, number)
      NM = NM@NeuronModel(Neuron, number);
      NM.number = number;
      NM.spikes = [];
    end
    
    function [NM] = updateNeurons(NM, IM, N, SM, dt)
      NM = updateNeurons@NeuronModel(NM, IM, N, SM, dt);
    end
    
    function spikes = get.spikes(NM)
      spikes = NM.spikes;
    end
    
  end % methods
end % classdef