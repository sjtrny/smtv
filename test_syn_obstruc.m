paths = ['common:'];
addpath(paths);

rng(1);

file_list = {'barbara.png', 'cameraman.bmp', 'lena.png', 'peppers.png'};

num_images = 5;

lambda_1 = 0.0001;
single_lambda_1 = 0.05;

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
        im = image + 1e-2*randn(size(image));
        
        good_entries{k} = reshape(imnoise(ones(m, n), 'salt & pepper', 0.1), 1, m*n);
        
        images{k} = reshape(im, m*n, d)' .* repmat(good_entries{k}, d, 1);

        tic;
        single_image = smtv(m*n, 1, images(k), R, single_lambda_1, lambda_2, good_entries(k), 'aniso');
        single_time(j, k) = toc;
        
        single_before_psnr(j, k) = psnr(image, im);
        single_img = reshape(single_image, m, n);
        single_after_psnr(j, k) = psnr(image, single_img);
       
        tic;
        gapg_img = tv_gapg(P, images{k}, m, n, R, gapg_lamba, 'aniso', good_entries{k}, 'aniso');
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
    A = smtv(m * n, num_images, images, R, lambda_1, lambda_2, good_entries, 'aniso');
    fuse_time(j) = toc;

    fused = reshape(A', [m, n, 1]);

    fuse_psnr(j) = psnr(image, fused);
    
    imwrite(fused, ['synob_' file_list{j} '_smtv_all.png'], 'png');
    imwrite(single_image_list{single_max_pos}, ['synob_' file_list{j} '_single_max.png'], 'png');
    imwrite(gapg_image_list{gapg_max_pos}, ['synob_' file_list{j} '_gapg_max.png'], 'png');
    imwrite(reshape(images{gapg_max_pos}, m, n), ['synob_' file_list{j} '_noisy.png'], 'png');
    
end

save('results_synthetic_obstruc', 'fuse_psnr', 'fuse_time', 'single_before_psnr', 'single_after_psnr', 'single_time', 'gapg_after_psnr', 'gapg_time');

rmpath(paths);