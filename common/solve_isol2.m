function [ E ] = solve_isol2( b, lambda )
%
% arg min_{x} ||x - b||_{2}^{2} + lambda*||x||_{2}
%

% This function assumes each b is of length 2

W = reshape(b', 2, (size(b, 2)/2) * size(b,1));

E = zeros(size(W));

norm_cols = sqrt(sum(W.^2));

for i = 1 : 2
    E(i,:) = (max(abs(norm_cols) - lambda, 0).*sign(norm_cols)) .* W(i,:) ./ max(1e-6,norm_cols) ; 
end

E = reshape(E, size(b,2), size(b, 1))';

end

