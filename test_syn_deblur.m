paths = ['common:'];
addpath(paths);

rng(1);

file_list = {'barbara.png', 'cameraman.bmp', 'lena.png', 'peppers.png'};
% file_list = {'barbara.png'};

num_images = 5;

lambda_1 = 0.01;
gapg_lambda = 0.0001;

lambda_2 = ones(num_images,1);

fuse_psnr = zeros(length(file_list), 1);
fuse_time = zeros(length(file_list), 1);

single_before_psnr = zeros(length(file_list), num_images);
single_after_psnr = zeros(length(file_list), num_images);
single_time = zeros(length(file_list), num_images);

gapg_after_psnr = zeros(length(file_list), num_images);
gapg_time = zeros(length(file_list), num_images);

% P = fspecial('gaussian',[9, 9],4);
% P = P/sum(P(:));

for j = 1 : length(file_list)
    
    image = double(imread(['images/' file_list{j}]))/255;

    [m, n, d] = size(image);
    
    R = get_R(m, n);

    images = cell(1, num_images);
    good_entries = cell(1, num_images);
    p_list = cell(1, num_images);

    for k = 1 : num_images
        P = fspecial('gaussian',[9, 9],4) + 1e-3*randn(9,9);
        P = P/sum(P(:));
        p_list{k} = P;
        
        im = imfilter(image,P,'symmetric')+ 1e-3*randn(size(image));

        images{k} = reshape(im, m*n, d)';

        good_entries{k} = ones(1, m*n);
        
        tic;
        single_image = smtv_deblur(m, n, 1, images(k), R, lambda_1, lambda_2, good_entries(k), p_list(k), 'aniso');
        single_time(j, k) = toc;
        
        single_before_psnr(j, k) = psnr(image, im);
        single_after_psnr(j, k) = psnr(image, reshape(single_image, m, n));
       
        tic;
        gapg_img = tv_gapg(P, images{k}, m, n, R, gapg_lambda, 'aniso');
        gapg_time(j, k) = toc;
       
        gapg_img = reshape(gapg_img, m, n);
        gapg_after_psnr(j, k) = psnr(image, gapg_img);
        
    end

    tic;
    A = smtv_deblur(m, n, num_images, images, R, lambda_1, lambda_2, good_entries, p_list, 'aniso');
    fuse_time(j) = toc;

    fused = reshape(A', [m, n, 1]);

    fuse_psnr(j) = psnr(image, fused);
    
end

save('results_synthetic_deblur', 'fuse_psnr', 'fuse_time', 'single_before_psnr', 'single_after_psnr', 'single_time', 'gapg_after_psnr', 'gapg_time');

rmpath(paths);