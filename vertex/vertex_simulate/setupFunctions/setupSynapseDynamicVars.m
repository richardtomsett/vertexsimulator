function [SynapseModelArr, synMapCell] = setupSynapseDynamicVars(TP, NP, CP, SS)

paramsMapCell = cell(TP.numGroups,1);
synMapCell = cell(TP.numGroups,1);
numSynTypes = 0;
for iPost = 1:TP.numGroups
  postSynDetails = cell(TP.numGroups,1);
  for iPre = 1:TP.numGroups
    model = lower(CP(iPre).synapseType{iPost});
    if ~isempty(model)
      params = eval(['SynapseModel_' model '.getRequiredParams();']);
      for iP = 1:length(params)
        model = [model, num2str(CP(iPre).(params{iP}){iPost})];
      end
      postSynDetails{iPre} = model;
    else
      postSynDetails{iPre} = '';
    end
  end
  [~, paramsMap, synMap] = unique(postSynDetails);
  paramsMapCell{iPost, 1} = paramsMap;
  synMapCell{iPost} = synMap;
  if length(paramsMap) > numSynTypes
    numSynTypes = length(paramsMap);
  end
end

constructorCell = cell(TP.numGroups, numSynTypes);
for iPost = 1:TP.numGroups
  % List of synapse model function handles
  if ~isempty(paramsMapCell{iPost})
    for iSynType = 1:numSynTypes
      if iSynType <= length(paramsMapCell{iPost})
        preID = paramsMapCell{iPost}(iSynType);
        modelName = lower(CP(preID).synapseType{iPost});
        funString = ['SynapseModel_' modelName];
        
        if ~strcmp(funString(end), '_')
          constructor = str2func(funString);
          constructorCell{iPost, iSynType} = constructor;
        %else
        %  constructorCell{iPost, iSynType} = [];
        end
      %else
      %  constructorCell{iPost, iSynType} = [];
      end
    end
  end
end

if SS.parallelSim
  spmd
    SynapseModelArr = cell(TP.numGroups, numSynTypes);
    for iPost = 1:TP.numGroups
      for iSynType = 1:numSynTypes
        if ~isempty(constructorCell{iPost, iSynType})
          preID = paramsMapCell{iPost}(iSynType);
          constructor = constructorCell{iPost, iSynType};
          SynapseModelArr{iPost, iSynType} = ...
            constructor(NP(iPost),CP(preID), ...
            SS,iPost, TP.numInGroupInLab(iPost, labindex()));
        else
          SynapseModelArr{iPost, iSynType} = [];
        end
      end
    end
  end
else
  numInGroup = diff(TP.groupBoundaryIDArr);
  SynapseModelArr = cell(TP.numGroups, numSynTypes);
  for iPost = 1:TP.numGroups
    for iSynType = 1:numSynTypes
      if ~isempty(constructorCell{iPost, iSynType})
        preID = paramsMapCell{iPost}(iSynType);
        constructor = constructorCell{iPost, iSynType};
        SynapseModelArr{iPost, iSynType} = ...  
          constructor(NP(iPost),CP(preID),SS,iPost,numInGroup(iPost));
      else
        SynapseModelArr{iPost, iSynType} = [];
      end
    end
  end
end