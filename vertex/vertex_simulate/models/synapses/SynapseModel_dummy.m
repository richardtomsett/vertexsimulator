classdef SynapseModel_dummy < handle
  %SynapseModel_dummy A dummy synapse that doesn't do anything
  properties (SetAccess = protected)
    I_syn
  end
  
  methods
    function SM = SynapseModel_dummy(~, ~, ~, ~, ~)
      SM.I_syn = 0;
    end
    
    function I_syn = get.I_syn(SM)
      I_syn = SM.I_syn;
    end
       
  end
  
  
  methods(Static)
    function params = getRequiredParams()
      params = {};
    end
    
    function [] = updateSynapses(~,~,~)
    end
    
    function [] = updateBuffer(~)
    end
  end
end

