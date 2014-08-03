function [] = checkInput(input, className, Range)

%narginchk(2, 3);

if ~ischar(class(className))
  errMsg = strcat('className must be a character array.');
  error('vertex:checkInput:wrongClass', errMsg);
end

if nargin == 3 % if Range struct specified...
  if ~isstruct(Range)
    errMsg = strcat('Range must be a struct.');
    error('vertex:checkInput:wrongClass', errMsg);
  end

  % check fields in Range struct
  if ~isfield(Range, 'min') || ~isfield(Range, 'max')
    errMsg = strcat('Range structure specified but does not ', ...
                    'contain correct fields (needs: min, max).');
    error('vertex:checkInput:unspecifiedRange', errMsg);
  else
    if input < Range.min
      errMsg = strcat('Input is out of input range. Input: ', ...
                      num2str(input), ', minimum: ', ...
                      num2str(Range.min), '.');
      error('vertex:checkInput:inputOutOfRange', errMsg);
    elseif input > Range.max
      errMsg = strcat('Input is out of input range. Input: ', ...
                      num2str(input), ', maximum: ', ...
                      num2str(Range.max), '.');
      error('vertex:checkInput:inputOutOfRange', errMsg);
    end
  end
end

if ~ismember(class(input), className)
  errMsg = strcat('Input is of the wrong class. Input: ', ...
                  class(input), ', expected: ', className, '.');
  error('vertex:checkInput:wrongClass', errMsg);
end
    