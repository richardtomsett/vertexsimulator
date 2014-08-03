#include <mex.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  
  //---Inside mexFunction---
  
  //Declarations
  double *targetIDs, *targetComparts, *targetWeights, *outWeights;
  int i,j,s;
  int rowLen;
  int numSame;
  
  targetIDs = mxGetPr(prhs[0]);
  rowLen = mxGetN(prhs[0]);
  targetComparts = mxGetPr(prhs[1]);
  targetWeights = mxGetPr(prhs[2]);
  
  //Allocate memory and assign output pointer
  plhs[0] = mxCreateDoubleMatrix(1, rowLen, mxREAL); //mxReal is data-type
  
  //Get a pointer to the data space in the newly allocated memory
  outWeights = mxGetPr(plhs[0]);
  
  numSame = 0;
  outWeights[0] = targetWeights[0];
  for(j=1; j != rowLen; j++)
  {
    outWeights[j] = targetWeights[j];
    if(targetIDs[j]==targetIDs[j-1])
    {
      numSame++;
      for(s=numSame; s!=0; s--)
      {
        if(targetComparts[j]==targetComparts[j-s])
        {
          outWeights[j-s] = outWeights[j-s] + outWeights[j];
          outWeights[j] = 0;
        }
      }
    }
    else
    {
      numSame = 0;
    }
  }
  
  return;
}