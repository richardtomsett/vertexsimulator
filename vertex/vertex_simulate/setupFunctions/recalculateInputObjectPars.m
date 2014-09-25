function [Inputs] = recalculateInputObjectPars(Inputs, TP, NP, SS)
% Recalculates the pre-optimised parameters for random Ornstein-Uhlenbeck
% process inputs
if SS.parallelSim
  spmd
    for iGroup = 1:size(Inputs, 1)
      for iIn = 1:size(Inputs, 2)
        if ~isempty(strfind(class(Inputs{iGroup,iIn}), '_ou'))
          subsetInLab = find(SS.neuronInLab==labindex());
          subsetInLab = subsetInLab( ...
            subsetInLab <= TP.groupBoundaryIDArr(iGroup+1) & ...
            subsetInLab > TP.groupBoundaryIDArr(iGroup)) - ...
            TP.groupBoundaryIDArr(iGroup);
        
          Inputs{iGroup,iIn} = ...
            precalculateOUpars(Inputs{iGroup,iIn}, NP(iGroup), ...
            iIn, SS.timeStep, subsetInLab);
        end
      end
    end
  end
else
  numInGroup = diff(TP.groupBoundaryIDArr);
  for iGroup = 1:size(Inputs, 1)
    for iIn = 1:size(Inputs, 2)
      if ~isempty(strfind(class(Inputs{iGroup,iIn}), '_ou'))
        Inputs{iGroup,iIn} = ...
          precalculateOUpars(Inputs{iGroup,iIn}, NP(iGroup), ...
          iIn, SS.timeStep, 1:numInGroup(iGroup));
      end
    end
  end
end
