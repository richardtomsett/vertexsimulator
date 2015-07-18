classdef PointNeuronModel_adex < PointNeuronModel
  %PointNeuronModel_adex Adaptive Exponential Integrate and Fire neuron model
  %(single compartment)
  %   Parameters to set in NeuronParams in addition to passive parameters:
  %   - a, the adaptation coupling parameter (in nS)
  %   - b, the post-spike adaptation current increase (in pA)
  %   - tau_w, the adaptation time constant (in ms)
  %   - delta_t, the spike steepness (in mV)
  %   - V_t, the spike current initiation threshold
  %   - v_cutoff, the spike cutoff value (in mV, recommended to set to V_t+5 mV)
  
  properties (SetAccess = private)
    w
    spikes
  end
  
  methods
    function NM = PointNeuronModel_adex(Neuron, number)
      NM = NM@PointNeuronModel(Neuron, number);
      NM.v = Neuron.E_leak .* ones(number, 1);
      NM.w = zeros(number, 1);
      NM.spikes = [];
    end
    
    function [NM] = updateNeurons(NM, IM, N, SM, dt)
      I_syn = PointNeuronModel.sumSynapticCurrents(SM);
      I_input = PointNeuronModel.sumInputCurrents(IM);
      kv = ((-N.g_l .* (NM.v - N.E_leak)) + ...
            ( N.g_l .* N.delta_t .* exp((NM.v - N.V_t)./N.delta_t)) - ...
            I_syn + I_input - NM.w) ./ N.C_m;
      
      kw = (N.a .* (NM.v - N.E_leak) - NM.w) ./ N.tau_w;
      
      k2v_in = NM.v + 0.5 .* dt .* kv;
      k2w_in = NM.w + 0.5 .* dt .* kw;
      
      kv = ((-N.g_l .* (k2v_in - N.E_leak)) + ...
            ( N.g_l .* N.delta_t .* exp((k2v_in - N.V_t)./N.delta_t)) - ...
            I_syn + I_input - NM.w) ./ N.C_m;
      
      kw = (N.a .* (NM.v - N.E_leak) - k2w_in) ./ N.tau_w;
      
      NM.v = NM.v + dt .* kv;
      NM.w = NM.w + dt .* kw;
      
      NM.spikes = NM.v(:,1) >= N.v_cutoff;
      NM.v(NM.spikes, 1) = N.v_reset;
      NM.w(NM.spikes, 1) = NM.w(NM.spikes, 1) + N.b;
    end
    
    function spikes = get.spikes(NM)
      spikes = NM.spikes;
    end
    
    function NM = randomInit(NM, N)
      NM.v = N.v_reset - (rand(size(NM.v)) .* 5);
      NM.w = rand(size(NM.w)) .* N.b/3;
    end
  end % methods
  
  methods(Static)
    
    function params = getRequiredParams()
      params = [getRequiredParams@PointNeuronModel, ...
                {'C_m','g_l','E_leak','a','b','tau_w','delta_t','V_t','v_cutoff'}];
    end
    
  end
end % classdef