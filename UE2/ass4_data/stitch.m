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

    function stitchA()
        points = vl_sift(single(rgb2gray(images{1})));
        imshow(images{1});
        vl_plotframe(points);
    end


    function stitchB(img1, img2)
        [pointsImg1, descImg1] = vl_sift(single(rgb2gray(img1)));
        [pointsImg2, descImg2] = vl_sift(single(rgb2gray(img2)));
        matches = vl_ubcmatch(descImg1, descImg2);
        points1 = pointsImg1(1:2, matches(1,:));
        points2 = pointsImg2(1:2, matches(2,:));
        match_plot(im2double(img1), im2double(img2), points1', points2');
    end

stitchA();

stitchB(images{1}, images{2});

end

