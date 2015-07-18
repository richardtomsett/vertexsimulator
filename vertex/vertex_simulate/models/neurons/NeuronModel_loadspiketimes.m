classdef NeuronModel_loadspiketimes < NeuronModel
  %NeuronModel_loadspiketimes Neurons with predefined spike times
  %   Parameters to set in NeuronParams in addition to passive parameters:
  %   - spikeTimeFile, the location of the MAT file with the pre-generated
  %   spike times to load for this group
  
  properties (SetAccess = private)
    number
    simulationStepCounter
    neuronCounter
    spikeTimeMat
    spikes
  end
  
  methods
    function NM = NeuronModel_loadspiketimes(Neuron, number, spikeTimeCell)
      NM = NM@NeuronModel(Neuron, number);
      NM.v = Neuron.E_leak .* ones(number, Neuron.numCompartments);
      NM.number = number;
      NM.simulationStepCounter = 1;
      NM.neuronCounter = ones(number, 1);
      NM.spikeTimeMat = NeuronModel_loadspiketimes.stCell2stMat(spikeTimeCell);
      NM.spikes = [];
    end
    
    function [NM] = updateNeurons(NM, IM, N, SM, dt)
      NM = updateNeurons@NeuronModel(NM, IM, N, SM, dt); 
      idx = (1:NM.number)' + (NM.neuronCounter-1) .* size(NM.spikeTimeMat,1);
      NM.spikes = NM.spikeTimeMat(idx) == NM.simulationStepCounter;
      NM.neuronCounter(NM.spikes) = NM.neuronCounter(NM.spikes) + 1;
      NM.neuronCounter(NM.neuronCounter > size(NM.spikeTimeMat,2)) = size(NM.spikeTimeMat,2);
      NM.simulationStepCounter = NM.simulationStepCounter + 1;
    end
    
    function spikes = get.spikes(NM)
      spikes = NM.spikes;
    end
    
    function NM = set.simulationStepCounter(NM, simStep)
      NM.simulationStepCounter = simStep;
    end
    
  end % methods
  
  methods(Static)

    function params = getRequiredParams()
      params = [getRequiredParams@NeuronModel, ...
                {'spikeTimeFile'}];
    end
    
    function stMat = stCell2stMat(stCell)
      numSpikes = zeros(length(stCell),1);
      for ii = 1:length(stCell)
        numSpikes(ii) = length(stCell{ii});
      end
      maxSpikes = max(numSpikes);
      stMat = zeros(length(stCell), maxSpikes);
      for ii = 1:length(stCell)
        stMat(ii, 1:numSpikes(ii)) = stCell{ii};
      end
    end

  end % static methods
  
end % classdef