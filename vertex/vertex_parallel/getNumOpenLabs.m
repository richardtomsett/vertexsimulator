function numLabs = getNumOpenLabs()

if isNewMatlab()
  p = gcp('nocreate');
  if isempty(p)
    numLabs = 0;
  else
    numLabs = p.NumWorkers;
  end
else
  numLabs = matlabpool('size');
end