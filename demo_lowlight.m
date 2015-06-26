paths = ['common:'];
addpath(paths);

rng(1);

m = 500;
n = 500;
d = 3;

num_images = 5;

images = cell(1, num_images);
good_entries = cell(1, num_images);

for k = 1 : num_images
    image = double(imread(['images/text/' num2str(k) '.png']))/255;
    
    figure, imshow(image);
    drawnow;
    
    images{k} = reshape(image, m*n, d)';
    
    good_entries{k} = ones(d, m*n);
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