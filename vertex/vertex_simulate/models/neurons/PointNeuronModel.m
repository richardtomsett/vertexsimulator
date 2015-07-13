classdef PointNeuronModel < handle
  properties (SetAccess = protected)
    v
  end
  
  methods
    function NM = PointNeuronModel(~, number)
      NM.v = zeros(number, 1);
    end
    
    function [NM] = updateNeurons(NM, ~, ~, ~, ~)
      
    end
    
    function v = get.v(NM)
      v = NM.v;
    end

  end % methods
  
  methods(Static)

    function params = getRequiredParams()
      params = {};
    end
    
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