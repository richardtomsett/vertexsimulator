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
      first = true;
      for iSyn = 1:size(SM, 2)
        if ~isempty(SM{iSyn})
          if first
            I_syn = SM{iSyn}.I_syn();
            first = false;
          else
              I_syn = I_syn + SM{iSyn}.I_syn();
          end
        end
      end
      if first % no synapses to update, so return 0
        I_syn = 0;
      end
    end
    
    function [I_input] = sumInputCurrents(IM)
      I_input = 0;
      for iIn = 1:size(IM, 2)
        if iIn == 1
          if ~isempty(IM{iIn})
            I_input = IM{iIn}.I_input();
          end
        else
          if ~isempty(IM{iIn})
            I_input = I_input + IM{iIn}.I_input();
          end
        end
      end
    end
    
  end % methods(Static)
end % classdef
