classdef ProgressReporter < handle
  properties(SetAccess=protected)
    extraText
    progressCounter
    pcProgress
    pcToPrint
  end
  
  methods
    function PR = ProgressReporter(total, pcToPrint, text)
      if ceil(total) ~= total
        error('vertex:ProgressReporter:nonIntegerTotal', ...
              'ProgressReporter: total must be a positive integer')
      end
      
      m = mod(total, pcToPrint) + mod(100, pcToPrint);
      if m ~= 0
        while m ~=0
          pcToPrint = pcToPrint - 1;
          m = mod(total, pcToPrint) + mod(100, pcToPrint);
        end
      end
      d = 100 / pcToPrint;
      PR.pcToPrint = pcToPrint;
      PR.pcProgress = round(total/d:total/d:total);
      PR.progressCounter = 1;
      PR.extraText = text;
    end
    
    function [] = printProgress(PR, t)
      %if PR.progressCounter > length(PR.pcProgress)
        % do nothing
      %else
        if t == PR.pcProgress(PR.progressCounter)
          disp([num2str(PR.progressCounter * PR.pcToPrint) '% ' PR.extraText]);
          PR.progressCounter = PR.progressCounter + 1;
        end
      %end
    end
    
    function [] = reset(PR)
      PR.progressCounter = 1;
    end
  end
  
end