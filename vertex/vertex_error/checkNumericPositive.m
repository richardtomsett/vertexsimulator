function [passTest] = checkNumericPositive(in)

passTest = true;
if ~isnumeric(in) || in <= 0
  passTest = false;
end