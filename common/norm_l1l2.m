function L = norm_l1l2(x)
%% L1/L2 norm of X
%
% Created by Stephen Tierney
% stierney@csu.edu.au
%
    E = reshape(x', 2, (size(x, 2)/2) * size(x,1));
    L = 0;
    for i=1:size(E,2)
        L = L + norm(E(:,i));
    end
end
