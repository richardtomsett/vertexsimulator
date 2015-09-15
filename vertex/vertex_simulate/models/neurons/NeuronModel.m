classdef NeuronModel < handle
  properties (SetAccess = protected)
    v
    I_ax
    treeChildren
    %doUpdate
  end
  
  methods
    function NM = NeuronModel(Neuron, number)
      NM.v = zeros(number, Neuron.numCompartments);
      NM.I_ax = zeros(number, Neuron.numCompartments);
      NM.treeChildren = length(Neuron.adjCompart);
      %NM.doUpdate = true(size(NM.v, 1));
    end
    
    function [NM] = updateNeurons(NM, IM, N, SM, dt)
      I_syn = NeuronModel.sumSynapticCurrents(SM);
      I_input = NeuronModel.sumInputCurrents(IM);
      kv = bsxfun(@rdivide, (-bsxfun(@times, N.g_l, (NM.v - N.E_leak)) -...
        I_syn - NM.I_ax + I_input), N.C_m);
      
      k2v_in = NM.v + 0.5 .* dt .* kv;
      
      kv = bsxfun(@rdivide,(-bsxfun(@times, N.g_l,(k2v_in - N.E_leak)) -...
        I_syn - NM.I_ax + I_input), N.C_m);
      
      NM.v = NM.v + dt .* kv;
    end
    
    function [NM] = updateI_ax(NM, N)
      % update axial currents
      NM.I_ax = NM.I_ax .* 0;
      for iTree = 1:NM.treeChildren %3
        NM.I_ax(:, N.adjCompart{iTree}(1, :)) = ...
          NM.I_ax(:, N.adjCompart{iTree}(1, :)) + ...
          bsxfun(@times, N.g_ax{iTree}, ...
                         (NM.v(:, N.adjCompart{iTree}(1, :)) - ...
                         NM.v(:, N.adjCompart{iTree}(2, :))));
      end
    end
    
    function v = get.v(NM)
      v = NM.v;
    end
    
    function I_ax = get.I_ax(NM)
      I_ax = NM.I_ax;
    end
    
    %function NM = setSilentNeurons(NM, IDs)
    %  NM.doUpdate(IDs) = false;
    %end
    
    function s = spikes(NM)
      s = false(size(NM.v,1),1);
    end
    
  end % methods
  
  methods(Static)
    
    function params = getRequiredParams()
      params = {'C_m','g_l','g_ax','adjCompart','E_leak'};
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
          I_input = IM{iIn}.I_input();
        else
          I_input = I_input + IM{iIn}.I_input();
        end
      end
    end
    
  end % methods(Static)
end % classdef
