classdef PointNeuronModel_dummy < handle
  properties (SetAccess = protected)
    spikes
    v
  end
  
  methods
    function NM = PointNeuronModel_dummy(~, ~)
      NM.spikes = [];
      NM.v = 0;
    end
    
    function [NM] = updateNeurons(NM, ~, ~, ~, ~)
      %I_syn = PointNeuronModel.sumSynapticCurrents(SM);
      %I_input = PointNeuronModel.sumInputCurrents(IM);
      %kv = ((-N.g_l .* (NM.v - N.E_leak)) + I_syn + I_input) ./ N.C_m;
      %k2v_in = NM.v + 0.5 .* dt .* kv;
      %kv = ((-N.g_l .* (k2v_in - N.E_leak)) + I_syn + I_input) ./ N.C_m;
      %NM.v = NM.v + dt .* kv;
    end
    
    function spikes = get.spikes(NM)
      spikes = NM.spikes;
    end
    
    function v = get.v(NM)
      v = NM.v;
    end
    
  end % methods
  
  methods(Static)
    function [] = sumSynapticCurrents(~)

    end
    
    function [] = sumInputCurrents(~)

    end
  end % methods(Static)
end % classdef