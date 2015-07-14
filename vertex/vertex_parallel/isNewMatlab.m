function n = isNewMatlab()

n = false;
v = version();
if str2double(v(1:3)) >= 8.4
  n = true;
end