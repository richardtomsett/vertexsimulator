classdef SynapseModel < handle
  properties (SetAccess = protected)
    I_syn
  end
  
  methods
    function SM = SynapseModel(Neuron, number)
      SM.I_syn = zeros(number, Neuron.numCompartments);
    end
    
    function I_syn = get.I_syn(SM)
      I_syn = SM.I_syn;
    end
  end
  
  
  methods(Static)
    function params = getRequiredParams()
      params = {};
    end
  end
end

