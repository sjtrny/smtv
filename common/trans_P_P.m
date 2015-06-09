function [ X ] = trans_P_P( X, B, P, m, n, d )
%TRANS_P_P Summary of this function goes here
%   Detailed explanation goes here

X = reshape(imfilter(imfilter(reshape(X', [m, n, d]), P, 'symmetric') - reshape(B', [m, n, d]), P', 'symmetric'), m*n, d)';

end

