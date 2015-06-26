paths = ['common:'];
addpath(paths);

rng(1);

file_list = {'text', 'mandarin', 'owl', 'stationery', 'alien'};
% file_list = {'text'};

num_images = 5;

lambda_1 = 0.05;
% lambda_1 = 0.0001;

lambda_2 = ones(num_images,1);

m = 500;
n = 500;
d = 3;

avg_im = zeros([m, n, d]);

for j = 1 : length(file_list)
    
    R = get_R(m, n);

    images = cell(1, num_images);
    good_entries = cell(1, num_images);

    for k = 1 : num_images
        image = double(imread(['images/' file_list{j} '/' num2str(k) '.png']))/255;

        images{k} = reshape(image, m*n, d)';

        good_entries{k} = ones(1, m*n);
        
        single_image = smtv(m*n, 1, images(k), R, lambda_1, lambda_2, good_entries(k), 'aniso');
        
        imwrite(reshape(single_image', [m, n, d]), ['results_lowlight/' file_list{j} '_' num2str(k) '.png'], 'png');
        
        avg_im = avg_im + image;
        
    end

    avg_im = avg_im/5;
    
    A = smtv(m * n, num_images, images, R, lambda_1, lambda_2, good_entries, 'aniso');

    imwrite(reshape(A', [m, n, d]), ['results_lowlight/' file_list{j} '_fused.png'], 'png');
    
end

rmpath(paths);