paths = ['common:', 'libs/guided_filter'];
addpath(paths);

img_inds = [1, 3];
num_images = length(img_inds);

start_row = 3001;
end_row = 4000;
start_col = 1;
end_col = 1000;

m = end_row - start_row + 1;
n = end_col - start_col + 1;
d = 3;

images = cell(1, num_images);
good_entries = cell(1, num_images);

for k = 1 : num_images
    image = double(imread(['images/landsat_3/landsat_' num2str(img_inds(k)) '.png']))/255;
    mask = double(imread(['images/landsat_3/mask_' num2str(k) '.png']))/255;
    
    img = image(start_row:end_row, start_col:end_col, :);
    mask = mask(start_row:end_row, start_col:end_col);
    
    alpha = guidedfilter_color(img, mask, 10, 10^-2);
    
    alpha = double(alpha > 0.1);
    
    images{k} = reshape(img, m*n, d)';
    good_entries{k} = reshape(1 - alpha, 1, m*n);
end

lambda_1 = 0.0001;

lambda_2 = ones(num_images,1);

tic;
R = get_R(m, n);
toc;

tic;
A = smtv(m*n, num_images, images, R, lambda_1, lambda_2, good_entries, 'aniso');
toc;

fused = reshape(A', [m, n, d]);

figure, imshow(fused);

rmpath(paths);