classdef PointNeuronModel < handle
  properties (SetAccess = protected)
    v
  end
  
  methods
    function NM = PointNeuronModel(Neuron, number)
      NM.v = Neuron.E_leak .* ones(number, 1);
    end
    
    function [NM] = updateNeurons(NM, IM, N, SM, dt)
      I_syn = PointNeuronModel.sumSynapticCurrents(SM);
      I_input = PointNeuronModel.sumInputCurrents(IM);
      kv = ((-N.g_l .* (NM.v - N.E_leak)) + I_syn + I_input) ./ N.C_m;
      k2v_in = NM.v + 0.5 .* dt .* kv;
      kv = ((-N.g_l .* (k2v_in - N.E_leak)) + I_syn + I_input) ./ N.C_m;
      NM.v = NM.v + dt .* kv;
    end
    
    function v = get.v(NM)
      v = NM.v;
    end

  end % methods
  
  methods(Static)
    function [I_syn] = sumSynapticCurrents(SM)
      for iSyn = 1:size(SM, 2)
        if iSyn == 1
          I_syn = SM{iSyn}.I_syn();
        else
          I_syn = I_syn + SM{iSyn}.I_syn();
        end
      end
    end
    
    function [I_input] = sumInputCurrents(IM)
      for iIn = 1:size(IM, 2)
        if iIn == 1
          I_input = IM{iIn}.I_input();
        else
          I_input = I_input + IM{iIn}.I_input();
        end
      end
    end
    
  end % methods(Static)
end % classdef