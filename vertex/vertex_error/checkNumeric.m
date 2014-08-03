function [passTest] = checkNumeric(in)

passTest = true;
if ~isnumeric(in)
  passTest = false;
end