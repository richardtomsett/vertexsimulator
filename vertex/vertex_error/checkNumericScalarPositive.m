function [passTest] = checkNumericScalarPositive(in)

passTest = true;
if ~isnumeric(in) || ~isequal(size(in), [1, 1]) || in <= 0
  passTest = false;
end