function [passTest] = checkNumericScalar(in)

passTest = true;
if ~isnumeric(in) || ~isequal(size(in), [1, 1])
  passTest = false;
end