function [SynapseModelArr, synMapCell] = setupSynapseDynamicVars(TP, NP, CP, SS)

paramsMapCell = cell(TP.numGroups,1);
synMapCell = cell(TP.numGroups,1);
numSynTypes = 0;
for iPost = 1:TP.numGroups
  postSynDetails = cell(TP.numGroups,1);
  for iPre = 1:TP.numGroups
    maxSynTypes = 1;
    if iscell(CP(iPre).synapseType{iPost})
      multiSynType = true;
      if length(CP(iPre).synapseType{iPost}) > maxSynTypes
        maxSynTypes = length(CP(iPre).synapseType{iPost});
      end
      for iType = 1:length(CP(iPre).synapseType{iPost})
        model = lower(CP(iPre).synapseType{iPost}{iType});
        if ~isempty(model)
          params = eval(['SynapseModel_' model '.getRequiredParams();']);
          for iP = 1:length(params)
            model = [model, num2str(CP(iPre).(params{iP}){iPost}{iType})];
          end
          postSynDetails{iPre,iType} = model; % TEST THIS! iType expansion etc WONT WORK LIKE THIS because of how unique() works, needs other solution
        else
          postSynDetails{iPre,iType} = '';
        end
      end
    else
      multiSynType = false;
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
  end
  nst = zeros(maxSynTypes, 1);
  for iType = 1:maxSynTypes
    % Get the IDs of the unique synapses in the postSynDetails array
    % paramsMap contains the indeces in postSynDetails to find the relevant
    % synapse types (length numSynTypes)
    % synMap contains the indeces of the synapse types for the presynaptic
    % groups to send spikes to (length numGroups)
    [~, paramsMap, synMap] = unique(postSynDetails(:, iType));
    if isempty(paramsMapCell{iPost})
      paramsMapCell{iPost} = paramsMap(:);
    else
      paramsMapCell{iPost} = [paramsMapCell{iPost} paramsMap(:)];
    end
    if isempty(synMapCell{iPost})
      synMapCell{iPost} = synMap(:);
    else
      synMapCell{iPost} = [synMapCell{iPost} synMap(:)];
    end
    if length(paramsMap) > nst(iType)
      nst(iType) = length(paramsMap);
    end
  end
  if sum(nst) > numSynTypes
    numSynTypes = sum(nst);
  end
end

% Need to get (rows,cols) of paramsMapCell and make sure we are selecting
% the synapse type to make from the correct column
constructorCell = cell(TP.numGroups, numSynTypes);
for iPost = 1:TP.numGroups
  % List of synapse model function handles
  if ~isempty(paramsMapCell{iPost})
    pmRows = size(paramsMapCell{iPost}, 1);
    pmCols = size(paramsMapCell{iPost}, 2);
    for iSynType = 1:numSynTypes
      if iSynType <= length(paramsMapCell{iPost}(:))
        preID = paramsMapCell{iPost}(iSynType);
        if multiSynType
          col = ceil(iSynType / pmRows);
          modelName = lower(CP(preID).synapseType{iPost}{col});
        else
          modelName = lower(CP(preID).synapseType{iPost});
        end
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
      pmRows = size(paramsMapCell{iPost}, 1);
      for iSynType = 1:numSynTypes
        if ~isempty(constructorCell{iPost, iSynType})
          preID = paramsMapCell{iPost}(iSynType);
          if multiSynType
            col = ceil(iSynType / pmRows);
          else
            col = 0;
          end
          constructor = constructorCell{iPost, iSynType};
          SynapseModelArr{iPost, iSynType} = ...
            constructor(NP(iPost),CP(preID), col,  ...
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
    pmRows = size(paramsMapCell{iPost}, 1);
    for iSynType = 1:numSynTypes
      if ~isempty(constructorCell{iPost, iSynType})
        preID = paramsMapCell{iPost}(iSynType);
        if multiSynType
          col = ceil(iSynType / pmRows);
        else
          col = 0;
        end
        constructor = constructorCell{iPost, iSynType};
        SynapseModelArr{iPost, iSynType} = ...
          constructor(NP(iPost),CP(preID),col,SS,iPost,numInGroup(iPost));
      else
        SynapseModelArr{iPost, iSynType} = [];
      end
    end
  end
end