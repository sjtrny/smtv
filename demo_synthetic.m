paths = ['common:'];
addpath(paths);

rng(1);

image = double(imread('images/cameraman.bmp'))/255;

[m, n, d] = size(image);

num_images = 5;

images = cell(1, num_images);
good_entries = cell(1, num_images);

psnr_list = zeros(1, num_images);

for k = 1 : num_images
    im = image + 1e-1*randn(size(image));
    
    psnr_list(k) = psnr(image, im);
    
    images{k} = reshape(im, m*n, d)';
    
    good_entries{k} = ones(d, m*n);
end

psnr_list

lambda_1 = 0.1;

lambda_2 = ones(num_images,1);

tic;
R = get_R(m, n);
toc;

tic;
A = smtv(m*n, num_images, images, R, lambda_1, lambda_2, good_entries, 'aniso');
toc;

fused = reshape(A', [m, n, 1]);

fused_psnr = psnr(image, fused)

figure, imshow(fused);

test = zeros(size(A));

for k = 1 : num_images
    test = test + images{k};
end
test = test / num_images;

test = reshape(test', [m, n, 1]);

rmpath(paths);