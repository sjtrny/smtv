paths = ['common:'];
addpath(paths);

rng(1);

file_list = {'barbara.png', 'cameraman.bmp', 'lena.png', 'peppers.png'};

num_images = 5;

lambda = 0.1;
lambda_single = 0.05;
gapg_lamba = 0.1;

lambda_2 = ones(num_images,1);

fuse_psnr = zeros(length(file_list), 1);
fuse_time = zeros(length(file_list), 1);

single_before_psnr = zeros(length(file_list), num_images);
single_after_psnr = zeros(length(file_list), num_images);
single_time = zeros(length(file_list), num_images);

gapg_after_psnr = zeros(length(file_list), num_images);
gapg_time = zeros(length(file_list), num_images);

P = zeros(9,9);
P(5,5) = 1;

for j = 1 : length(file_list)
    
    image = double(imread(['images/' file_list{j}]))/255;

    [m, n, d] = size(image);
    
    R = get_R(m, n);

    images = cell(1, num_images);
    good_entries = cell(1, num_images);
    
    single_image_list = cell(1, num_images);
    gapg_image_list = cell(1, num_images);
    
    single_max_psnr = 0;
    single_max_pos = 0;
    gapg_max_psnr = 0;
    gapg_max_pos = 0;

    for k = 1 : num_images
        im = image + 1e-1*randn(size(image));

        images{k} = reshape(im, m*n, d)';

        good_entries{k} = ones(1, m*n);
        
        tic;
        single_image = smtv(m*n, 1, images(k), R, lambda_single, lambda_2, good_entries(k), 'aniso');
        single_time(j, k) = toc;
        
        single_before_psnr(j, k) = psnr(image, im);
        single_img = reshape(single_image, m, n);
        single_after_psnr(j, k) = psnr(image, single_img);
       
        tic;
        gapg_img = tv_gapg(P, images{k}, m, n, R, gapg_lamba, 'aniso');
        gapg_time(j, k) = toc;
       
        gapg_img = reshape(gapg_img, m, n);
        gapg_after_psnr(j, k) = psnr(image, gapg_img);
        
        single_image_list{k} = single_img;
        if (single_max_psnr < single_after_psnr(j, k))
            single_max_psnr = single_after_psnr(j, k);
            single_max_pos = k;
        end
        gapg_image_list{k} = gapg_img;
        if (gapg_max_psnr < gapg_after_psnr(j, k))
            gapg_max_psnr = gapg_after_psnr(j, k);
            gapg_max_pos = k;
        end
        
    end

    tic;
    A = smtv(m * n, num_images, images, R, lambda, lambda_2, good_entries, 'aniso');
    fuse_time(j) = toc;

    fused = reshape(A', [m, n, 1]);

    fuse_psnr(j) = psnr(image, fused);
    
    imwrite(fused, ['synden_' file_list{j} '_smtv_all.png'], 'png');
    imwrite(single_image_list{single_max_pos}, ['synden_'  file_list{j} '_single_max.png'], 'png');
    imwrite(gapg_image_list{gapg_max_pos}, ['synden_' file_list{j} '_gapg_max.png'], 'png');
    imwrite(reshape(images{gapg_max_pos}, m, n), ['synden_' file_list{j} '_noisy.png'], 'png');
    
end

save('results_synthetic_denoise', 'fuse_psnr', 'fuse_time', 'single_before_psnr', 'single_after_psnr', 'single_time', 'gapg_after_psnr', 'gapg_time');

rmpath(paths);