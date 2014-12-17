function stitch( name )

N = 100;
T = 5;
dir_ = 'img_input/';

imagesList = dir(strcat(dir_, name, '*'));      
imagesCount = length(imagesList);

if imagesCount < 2
    disp('problem reading images.');
    return;
end

REF = floor(imagesCount / 2) + 1;

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

    function [t] = imreg(img1, img2)
        [pointsImg1, descImg1] = vl_sift(single(rgb2gray(img1)));
        [pointsImg2, descImg2] = vl_sift(single(rgb2gray(img2)));
        matches = vl_ubcmatch(descImg1, descImg2);
        points1 = pointsImg1(1:2, matches(1,:));
        points2 = pointsImg2(1:2, matches(2,:));
        match_plot(im2double(img1), im2double(img2), points1', points2');
        
        best_inliers_ind = [];
        for n = 1:N
            rs = randsample(size(matches, 2), 4);
            try
                t = cp2tform(points1(:, rs)', points2(:, rs)', 'projective');
            catch ex
                disp(ex.message);
                continue;
            end
            [X, Y] = tformfwd(t, points1(1, :), points1(2, :));
            points1_t = [X; Y];
            diffs = points1_t - points2(1:2, :);
            dists = sqrt(sum(diffs.^2));
            inliers_ind = dists < T;
            if sum(inliers_ind) > sum(best_inliers_ind)
                best_inliers_ind = inliers_ind;
            end
        end
        
        t = cp2tform(points1(:, best_inliers_ind)', points2(:, best_inliers_ind)', 'projective');
        B = imtransform(img1, t, 'XData', [1 size(img2,2)], 'YData', [1 size(img2,1)], 'XYScale', [1 1]);
        %B(B == 0) = img2(B == 0);
        %figure; imshow(B);
    end

%stitchA();

%imreg(images{1}, images{2});

% stitching

for i = 1:(imagesCount - 1)
    left = images{i};
    right = images{i + 1};
    H{i, i+1} = imreg(left, right);
end

if REF > 2
    curr = 2;
     for i = 1:(REF-2)
              hTempLeft = H{REF-curr+1, REF}.tdata.T .* H{REF-curr, REF-curr+1}.tdata.T;
              H{REF-curr, REF} = maketform('projective', hTempLeft);
              
              if (REF+curr) <= imagesCount
                hTempRight = H{REF, REF+curr-1}.tdata.T .* H{REF+curr-1, REF+curr}.tdata.T;
                H{REF, REF+curr} = maketform('projective', hTempRight);
              end
              
              curr = curr +1;
     end
 end

%H{1,3} = maketform('composite', H{2,3}.tdata.T, H{1,2}.tdata.T);
%H{3,5} = maketform('composite', H{4,5}.tdata.T, H{3,4}.tdata.T);

xMin = inf;
yMin = inf;
xMax = 0;
yMax = 0;

for i = 1:imagesCount
    
    [height, width] = size(images{i});
    
    if i<REF
        outbounds = findbounds(H{i, REF},[0 0; height width]); %not sure if [0 0; height width] is correct
    elseif i>REF
        outbounds = findbounds(H{REF, i},[0 0; height width]); %not sure if [0 0; height width] is correct
    else
        continue;
    end
    
    %todo: compute the minimum x,minimum y, maximum x, and maximum y coordinates 
    
end
        
end