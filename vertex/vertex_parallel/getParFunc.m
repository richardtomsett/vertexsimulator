function parFunc = getParFunc()

if isNewMatlab()
  parFunc = str2func('parpool');
else
  parFunc = str2func('matlabpool');
end