function [total, convergent, divergent] = ...
  getGroupConnectivity(params, connectivity)
%GETGROUPCONNECTIVITY Get the number of connections between neuron groups.
%   TOTAL = GETGROUPCONNECTIVITY(PARAMS, CONNECTIVITY) returns the total
%   number of synapses made between each neuron group. The first input parameter
%   PARAMS - is the parameter structure returned by initNetwork(). The second
%   parameter CONNECTIVITY is either the connection cell array (serial mode) or
%   composite (parallel mode) returned by initNetwork(), or the sparse
%   connectivity matrix returned by getSparseConnectivity(). TOTAL is a
%   square matrix of size equal to PARAMS.TissueProperties.numGroups, where
%   rows represent postsynaptic groups and columns presynaptic groups.
%
%   [TOTAL, CONVERGENT, DIVERGENT] = GETGROUPCONNECTIVITY(PARAMS, CONNECTIVITY)
%   also returns the convergent and divergent connectivity. The convergent
%   connectivity is the mean number of connections received by a single neuron
%   in the postsynaptic group (rows) from all neurons in the presynaptic
%   group (columns). The divergent connectivity is the mean number of
%   connections made by a single neuron in the presynaptic group (columns)
%   to all neurons in the postsynaptic group (rows).

if issparse(connectivity)
  CM = connectivity;
else
  CM = getSparseConnectivity(params, connectivity);
end

numGroups = params.TissueParams.numGroups;
convergent = zeros(numGroups, numGroups);
divergent = zeros(numGroups, numGroups);
total = zeros(numGroups, numGroups);

disp('Calculating mean group connectivity ...');
for ii=1:numGroups
  for jj=1:numGroups
    start_i = params.TissueParams.groupBoundaryIDArr(ii)+1;
    stop_i = params.TissueParams.groupBoundaryIDArr(ii+1);
    start_j = params.TissueParams.groupBoundaryIDArr(jj)+1;
    stop_j = params.TissueParams.groupBoundaryIDArr(jj+1);
    convergent(ii, jj) = ...
      length(find(CM(start_i:stop_i,start_j:stop_j))) ./ ...
      params.TissueParams.groupSizeArr(ii);
    divergent(ii, jj) = ...
      length(find(CM(start_i:stop_i,start_j:stop_j))) ./ ...
      params.TissueParams.groupSizeArr(jj);
    total(ii, jj) = length(find(CM(start_i:stop_i,start_j:stop_j)));
  end
  disp(['Done ' num2str(ii) ' of ' num2str(numGroups) ' groups ...']);
end
disp('Finished calculting mean group connectivity!');