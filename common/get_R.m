function [ C ] = get_R( orig_m, orig_n )

n = orig_m * orig_n;

ind_mat = reshape( 1:n, orig_m, orig_n);

win_rad = 1;

row_mat = reshape(repmat([1:orig_m]', 1, orig_n), orig_m * orig_n, 1);
col_mat = reshape(repmat([1:orig_n], orig_m, 1), orig_m * orig_n, 1);

padded_mat = padarray(ind_mat,[1, 1]);

% [row_inds, col_inds, vals] = r_helper(orig_m, orig_n, n, win_rad, row_mat, col_mat, padded_mat);

[row_inds, col_inds, vals] = r2_helper(orig_m, orig_n, n, win_rad, row_mat, col_mat, padded_mat);

C = sparse(row_inds, col_inds, vals, n, max(col_inds));

end

