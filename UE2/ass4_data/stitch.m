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
        
        %visualize
        %match_plot(im2double(img1), im2double(img2), points1', points2');
        
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
        
        %B = imtransform(img1, t, 'XData', [1 size(img2,2)], 'YData', [1 size(img2,1)], 'XYScale', [1 1]);
        %B(B == 0) = img2(B == 0);
        %figure; imshow(B);
    end

%just for the theoretical part
%stitchA();
%imreg(images{1}, images{2});



% stitching

for i = 1:(imagesCount - 1)
    left = images{i};
    right = images{i + 1};
    if i<REF
        H{i, i+1} = imreg(left, right);
    else
        H{i, i+1} = fliptform(imreg(left, right));
    end
end

% make composite transformation matrices, if needed(more than 3 pics)
if REF > 2
    curr = 2;
     for i = 1:(REF-2)
              H{REF-curr, REF} = maketform('composite', H{REF-curr+1, REF}, H{REF-curr, REF-curr+1});
             
              if (REF+curr) <= imagesCount
                H{REF, REF+curr} = maketform('composite', H{REF, REF+curr-1}, H{REF+curr-1, REF+curr});
              end
              
              curr = curr +1;
     end
end


% estimate final panorama size
xMin = 1;
yMin = 1;
xMax = size(images{REF}, 2);
yMax = size(images{REF}, 1);

for i = 1:imagesCount
    
    [height, width, ~] = size(images{i});
    
    if i<REF
        outbounds = findbounds(H{i, REF},[1 height; width 1]);
    elseif i>REF
        outbounds = findbounds(H{REF, i},[1 height;width 1]);
    else
        continue;
    end
    
    if outbounds(1,1) < xMin
        xMin = outbounds(1,1);
    end
    
    if outbounds(1,2) < yMin
        yMin = outbounds(1,2);
    end
    
    if outbounds(2,1) > xMax
        xMax = outbounds(2,1);
    end
    
    if outbounds(2,2) > yMax
        yMax = outbounds(2,2);
    end
    
end


%transform images
for i = 1:imagesCount
    
    if i<REF
         B = imtransform(images{i}, H{i, REF}, 'XData', [xMin xMax], 'YData', [yMin yMax], 'XYScale', [1 1]);
    elseif i>REF
         B = imtransform(images{i}, H{REF, i}, 'XData', [xMin xMax], 'YData', [yMin yMax], 'XYScale', [1 1]);
    else
        B = imtransform(images{i},  maketform('projective',eye(3)), 'XData', [xMin xMax], 'YData', [yMin yMax], 'XYScale', [1 1]);
    end


    if i == 1
        test = B;
    else
        test(B ~= 0) = B(B~=0);
    end
end
        
figure;imshow(test);


end