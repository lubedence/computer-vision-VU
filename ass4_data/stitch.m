function stitch( name )

dir_ = 'img_input/';

imagesList = dir(strcat(dir_, name, '*'));      
imagesCount = length(imagesList);

if imagesCount < 2
    disp('problem reading images.');
    return;
end

for i=1:imagesCount
   imageName = imagesList(i).name;
   currentImage = imread(strcat(dir_,imageName));
   images{i} = currentImage;
end

firstImageGS =  rgb2gray(images{1});
points = vl_sift(single(firstImageGS));
imshow(firstImageGS);
vl_plotframe(points);
end

