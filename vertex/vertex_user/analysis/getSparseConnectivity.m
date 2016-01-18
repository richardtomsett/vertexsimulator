function [sparseConnectivity] = getSparseConnectivity(params, connections)
%GETSPARSECONNECTIVITY Gets the sparse connectivity matrix for the network.
%   SPARSECONNECTIVITY = GETSPARSECONNECTIVITY(PARAMS, CONNECTIONS)
%   calculates a sparse matrix representation of the connections between
%   all the neurons in the model. The first input parameter PARAMS - is the
%   parameter structure returned by initNetwork(). The second parameter 
%   CONNECTIONS is the connection cell array (serial mode) or composite 
%   (parallel mode) returned by initNetwork(). Rows in the returned sparse
%   matrix represent the IDs of presynaptic neurons and columns the IDs of
%   postsynaptic neurons. If neuron i synapses onto synapse j, then
%   SPARSECONNECTIVITY(i,j) will contain the number of synapses made from i
%   to j, otherwise it will be 0.

if params.SimulationSettings.parallelSim
  parallelSim = true;
  numLabs = params.SimulationSettings.poolSize;
else
  parallelSim = false;
  numLabs = 1;
end

N = params.TissueParams.N;

presumedMaxConnections = 6000;
allpost = zeros(N*presumedMaxConnections, 1, 'uint32');
allpre = zeros(N*presumedMaxConnections, 1, 'uint32');
alldel = zeros(N*presumedMaxConnections, 1, 'uint16');

count = 0;
for iLab = 1:numLabs
  if parallelSim
    sa = connections{iLab};
  else
    sa = connections;
  end
  for iN = 1:size(sa, 1)
    s = sa{iN, 1};
    allpost(count+1:count+length(s)) = s;
    allpre(count+1:count+length(s)) = iN;
    alldel(count+1:count+length(s)) = sa{iN, 2};
    count = count+length(s);
  end
  if parallelSim
    disp([ num2str(iLab) ' labs done ...']);
  end
end

disp('Creating sparse matrix...');
sparseConnectivity = sparse(double(allpost(1:count)), ...
                            double(allpre(1:count)), ...
                            double(alldel(1:count)./alldel(1:count)), N, N);
disp('Done!');