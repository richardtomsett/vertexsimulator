function [] = checkStructFields(StructIn, fieldCell, ...
                                classCell, dimensionCell)

%narginchk(2, 4);
checkInput(StructIn, 'struct');
checkInput(fieldCell, 'cell');
fieldCell = fieldCell(:);
if nargin >= 3
  checkInput(classCell, 'cell');
  classCell = classCell(:);
  if length(fieldCell) ~= length(classCell)
    errMsg = strcat('fieldCell and classCell must be same length.');
    error('vertex:checkStructContents:cellLengthMismatch', errMsg);
  end
  wrongClassCell = cell(length(classCell), 3);
  if nargin == 4
    checkInput(dimensionCell, 'cell');
    dimensionCell = dimensionCell(:);
    if length(fieldCell) ~= length(dimensionCell)
      errMsg = strcat('fieldCell and dimensionCell must be same length.');
      error('vertex:checkStructContents:cellLengthMismatch', errMsg);  
    end
  wrongDimensionCell = cell(length(dimensionCell), 3);
  end
end

mcount = 0;
wcount = 0;
dcount = 0;
missingFieldCell = cell(length(fieldCell), 1);
for iC = 1:size(fieldCell, 1)
  if ~isfield(StructIn, fieldCell{iC})
    mcount = mcount + 1;
    missingFieldCell{mcount, 1} = strcat(fieldCell{iC}, ', ');
  elseif nargin >= 3
    if ~strcmpi(class(StructIn.(fieldCell{iC})), classCell{iC})
      wcount = wcount + 1;
      wrongClassCell{wcount, 1} = strcat('Field name: ', ...
                                  fieldCell{iC},'\t');
      wrongClassCell{wcount, 2} = strcat('Class given: ', ...
                                  class(StructIn.(fieldCell{iC})), '\t');
      wrongClassCell{wcount, 3} = strcat('Class expected: ', ...
                                  classCell{iC}, '.');
    end
    if nargin == 4
      sizeGiven = size(StructIn.(fieldCell{iC}));
      if ~isempty(dimensionCell{iC})
        if length(dimensionCell{iC}) == length(sizeGiven)
          if ~isequal(sizeGiven, dimensionCell{iC})
            dcount = dcount + 1;
            wrongDimensionCell{dcount, 1} = strcat('Field name: ', ...
                                    fieldCell{iC},'\t');
            wrongDimensionCell{dcount, 2} = strcat('Dimensions given: ', ...
                                  num2str(sizeGiven), '\t');
            wrongDimensionCell{dcount, 3} = strcat('Dimensions expected: ', ...
                                    num2str(dimensionCell{iC}), '.');
          end
        else % only 1 dimension size specified, we assume
          if ~all(ismember(dimensionCell{iC}, sizeGiven))
            dcount = dcount + 1;
            wrongDimensionCell{dcount, 1} = strcat('Field name: ', ...
                                  fieldCell{iC},'\t');
            wrongDimensionCell{dcount, 2} = strcat('Dimensions given: ', ...
                                    num2str(sizeGiven), '\t');
            wrongDimensionCell{dcount, 3} = ...
                strcat('Expected one dimension to be length ', ...
                                    num2str(dimensionCell{iC}), '.');
          end
        end
      end
    end
  end
end

errMsg = '';
if mcount > 0
  errMsg = strcat(errMsg, 'Structure is missing essential fields: ', ...
                  cell2mat(missingFieldCell(1:mcount)'), '\n');
end
if wcount > 0
  errMsg = strcat(errMsg, 'Fields with incorrect class: \n');
  for iW = 1:wcount
      errMsg = strcat(errMsg, cell2mat(wrongClassCell(iW, :)), '\n');
  end
end
if dcount > 0
  errMsg = strcat(errMsg, 'Fields with incorrect dimension: \n');
  for iD = 1:dcount
      errMsg = strcat(errMsg, cell2mat(wrongDimensionCell(iD, :)), '\n');
  end
end

if mcount > 0 || wcount > 0 || dcount > 0
  error('vertex:checkStructContents:wrongStructContents', errMsg);
end