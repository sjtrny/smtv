% im_dir = 'text';
% start_row = 1000;
% end_row = 1499;
% start_col = 1600;
% end_col = 2099;

% im_dir = 'mandarin';
% start_row = 500;
% end_row = 999;
% start_col = 1000;
% end_col = 1499;

% im_dir = 'owl';
% start_row = 500;
% end_row = 999;
% start_col = 1700;
% end_col = 2199;

% im_dir = 'stationery';
% start_row = 800;
% end_row = 1299;
% start_col = 1200;
% end_col = 1699;

im_dir = 'alien';
start_row = 800;
end_row = 1299;
start_col = 2000;
end_col = 2499;

num_images = 5;

for k = 1 : num_images
    image = double(imread([im_dir '/source_' num2str(k) '.JPG']))/255;
    
    cropped_image = image(start_row:end_row, start_col:end_col,:);
    
    imwrite(cropped_image, [im_dir '/' num2str(k) '.png'], 'png');
end