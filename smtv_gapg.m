function [ A, func_vals ] = smtv_gapg(P, m, n, images, R, lambda, lambda_2, good_entries, tv_type)
%% Solves the following
%
% min_{A}   lambda * TV(A) + 1/2 | (A - I_i) D_i |^2
%
%   via APG
%
% Created by Stephen Tierney
% stierney@csu.edu.au
%

if(strcmp(tv_type, 'iso'))
    h_tv_solver = @solve_isol2;
elseif(strcmp(tv_type, 'aniso'))
    h_tv_solver = @solve_l1;
else
    error('Unidentified TV type. Use "iso" or "aniso".')
end

max_iterations = 100;

func_vals = zeros(max_iterations, 1);
last_f_value = Inf;

N_images = length(images);
N_pixel = m*n;
d = size(images{1}, 1);

mu = 0;
for k = 1 : N_images
    mu = max(mu, norm(images{k}, 'fro'));
end
mu_min = 1e-3*mu;

P_2_est = min(sqrt(sum(abs(P(:))>0)*sum(P(:).*P(:))), sum(abs(P(:))));
eta = 1;
rho = (sqrt(mu)*P_2_est + 4*sqrt(eta))^2;

A = images{1};

U = A*R;

Y_A = A;
Y_U = U;

D = cell(1, N_images);

for k = 1 : N_images
    D{k} = lambda_2(k) * spdiags(good_entries{k}', 0, N_pixel, N_pixel);
end

t = 1;

tol = 1*10^-10;

for k = 1 : max_iterations
    
    A_prev = A;
    U_prev = U;
    t_prev = t;

    % Update A
    Pt_P_A = zeros(size(A));
    f_rhs = zeros(N_images,1);
    for j = 1 : N_images
        Pt_P_A = Pt_P_A + ( trans_P_P(Y_A, images{j}, P, m, n, d))*D{j};
        f_rhs(j, 1) = 0.5 * norm( (reshape(imfilter(reshape(A', [m, n, d]), P, 'symmetric'), m*n, d)' - images{j})*D{j}, 'fro')^2;
    end
    A = Y_A - 1/rho * (Pt_P_A + (Y_U - Y_A* R) * R');
    
%     x = max(x, 0);
%     x = min(x, 1);
    
%     u = reshape(h_tv_solver( reshape(y_u - (1/eta) * (y_u - C * y_x), 2, length(u)/2), (mu*lambda)/eta), length(u), 1);

    U = h_tv_solver(Y_U - (1/eta) * (Y_U - Y_A * R), (mu*lambda)/eta);

    t = (1 + sqrt(1 + 4*t_prev^2)) / 2;
    
    Y_A = A + ((t_prev - 1)/t) * (A - A_prev);
    
    Y_U = U + ((t_prev - 1)/t) * (U - U_prev);
    
    rat = ((2*k-2)/(2*k))^0.125; 
    mu = max(mu*(0.1*rat + 0.9), mu_min);
    rho = (sqrt(mu)*P_2_est + 4*sqrt(eta))^2;
    
    func_vals(k) = lambda*norm_l1(A*R) + sum(f_rhs);
    
    if (abs(last_f_value -  func_vals(k)) <= tol)
        break;
    else
        last_f_value = func_vals(k);
    end
    
end

end