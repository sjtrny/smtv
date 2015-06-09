#include <math.h>
#include <matrix.h>
#include <mex.h>
#include <string.h>

#define sign(a) ( ( (a) < 0 )  ?  -1   : ( (a) > 0 ) )
#define MAX(x, y) (((x) > (y)) ? (x) : (y))
#define MIN(x, y) (((x) < (y)) ? (x) : (y))

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int orig_m = (int)*mxGetPr(prhs[0]);
    int orig_n = (int)*mxGetPr(prhs[1]);
    int n = (int)*mxGetPr(prhs[2]);
//     int win_rad = (int)*mxGetPr(prhs[3]);
    double *row_mat_pr = mxGetPr(prhs[4]);
    double *col_mat_pr = mxGetPr(prhs[5]);
    double *padded_mat = mxGetPr(prhs[6]);
    
//     int max_num_neigh = (win_rad*2+1)^2 -1;
    
    int max_num_entries = 8 * n * 2;
    
//     mexPrintf("Max num entries: %d\n", max_num_entries);
    
    double * row_inds = mxCalloc(max_num_entries, sizeof(double));
    double * col_inds = mxCalloc(max_num_entries, sizeof(double));
    double * vals = mxCalloc(max_num_entries, sizeof(double));
    
    double * window = mxCalloc(8, sizeof(double));
    
    int len = 0 ;
    int col_count = 1;
    
    for (int k = 0; k < n; k++)
    {
        int i = row_mat_pr[k];
        int j = col_mat_pr[k];
        
//         mexPrintf("%d, %d, ", i, j);
        
        int ind_in_pad = (orig_m+1) + j*2 + k;
        
//         mexPrintf("%d\n", ind_in_pad);
        
        // Top Left
        window[0] = padded_mat[ind_in_pad - 3 - orig_m];
        // Left
        window[1] = padded_mat[ind_in_pad - 2 - orig_m];
        // Bottom Left
        window[2] = padded_mat[ind_in_pad - 1 - orig_m];
        // Above
        window[3] = padded_mat[ind_in_pad - 1];
        // Below
        window[4] = padded_mat[ind_in_pad + 1];
        // Top Right
        window[5] = padded_mat[ind_in_pad + 1 + orig_m];
        // Right
        window[6] = padded_mat[ind_in_pad + 2 + orig_m];
        // Bottom Right
        window[7] = padded_mat[ind_in_pad + 3 + orig_m];
        
        for (int q = 0; q < 8; q++)
        {
            // if 0 or not 0 add index to lists
            if (window[q] != 0)
            {
                row_inds[len] = k + 1;
                row_inds[len + 1] = window[q];
                
                col_inds[len] = col_count;
                col_inds[len + 1] = col_count;
                
                vals[len] = 1;
                vals[len + 1] = -1;
                
                len = len + 2;
                
                col_count = col_count + 1;
            }
        }
        
    }
    
    plhs[0] = mxCreateNumericMatrix(0, 0, mxDOUBLE_CLASS, mxREAL);
    mxSetPr(plhs[0], row_inds);
    mxSetM(plhs[0], len);
    mxSetN(plhs[0], 1);
    
    plhs[1] = mxCreateNumericMatrix(0, 0, mxDOUBLE_CLASS, mxREAL);
    mxSetPr(plhs[1], col_inds);
    mxSetM(plhs[1], len);
    mxSetN(plhs[1], 1);
    
    plhs[2] = mxCreateNumericMatrix(0, 0, mxDOUBLE_CLASS, mxREAL);
    mxSetPr(plhs[2], vals);
    mxSetM(plhs[2], len);
    mxSetN(plhs[2], 1);
}