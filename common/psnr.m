function val = psnr(origImg, distImg, max)
%% PSNR 
%
% Created by Stephen Tierney
% stierney@csu.edu.au
%

if ~exist('max', 'var')
    max = 1;
end

origImg = double(origImg);
distImg = double(distImg);

[M, N] = size(origImg);
error = origImg - distImg;
MSE = sum(sum(error .* error)) / (M * N);

if(MSE > 0)
    val = 10*log10((max^2)/MSE);
else
    val = 99;
end