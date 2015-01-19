function stitch( name )

    N = 100; %loop, RANSAC
    T = 5; %threshold for inliers, RANSAC
    fadingBorder= 30; %for blending
    dir_ = 'img_input/';
    imagesList = dir(strcat(dir_, name, '*'));
    imagesCount = length(imagesList);

    if imagesCount < 2
        disp('problem reading images.');
        return;
    end

    REF = floor(imagesCount / 2) + 1; %reference image

    %read images and create feathering mask
    for i=1:imagesCount
        imageName = imagesList(i).name;
        currentImage = imread(strcat(dir_,imageName));
        images{i} = currentImage;

        %cylinder projection
        %currentImage = cylinder_projection(imread(strcat(dir_,imageName)),700,0,0);

        %alpha channel
        h = size(currentImage,1);
        w = size(currentImage,2);
        ac = zeros(h, w);
        ac(1:fadingBorder,:) = 1;
        ac(:,1:fadingBorder) = 1;
        ac((h-fadingBorder):h,:) = 1;
        ac(:,(w-fadingBorder):w) = 1;
        ac  =  bwdist(ac);
        alphaChannel{i} =  ac ./ max(max(ac)); %normalize mask
    end

    %just for the theoretical part
    function stitchA()
        points = vl_sift(single(rgb2gray(images{1})));
        imshow(images{1});
        vl_plotframe(points);
    end

    %returns transformation matrix, homography between img1 and img2
    function [t] = imreg(img1, img2)
        [pointsImg1, descImg1] = vl_sift(single(rgb2gray(img1)));
        [pointsImg2, descImg2] = vl_sift(single(rgb2gray(img2)));
        matches = vl_ubcmatch(descImg1, descImg2);
        points1 = pointsImg1(1:2, matches(1,:));
        points2 = pointsImg2(1:2, matches(2,:));
        
        %visualize all
        %match_plot(im2double(img1), im2double(img2), points1', points2');
        
        %perform RANSAC
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
        
        %visualize inliers
        %match_plot(im2double(img1), im2double(img2), points1(:, best_inliers_ind)', points2(:, best_inliers_ind)');
        
        %create and return projective transformation matrix
        t = cp2tform(points1(:, best_inliers_ind)', points2(:, best_inliers_ind)', 'projective');
        
        
        %just some output for the theoretical part
        
        %B = imtransform(img1, t, 'XData', [1 size(img2,2)], 'YData', [1 size(img2,1)], 'XYScale', [1 1]);
        %figure; imshow(img2);
        %B(B == 0) = img2(B == 0);
        %figure; imshow(B);
        %K = imabsdiff(B,img2);
        %figure; imshow(K,[]);
    end

%just for the theoretical part
%stitchA();
%imreg(images{1}, images{2});



%create transformation matrices for neighbours
for i = 1:(imagesCount - 1)
    left = images{i};
    right = images{i + 1};
    if i<REF
        H{i, i+1} = imreg(left, right);
    else
        %mirroring projection if images are on the right side of the ref.
        %image
        H{i, i+1} = fliptform(imreg(left, right));
    end
end

% calc composite transformation matrices. needed if there are more than 3
% images
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
        outbounds = findbounds(H{REF, i},[1 height; width 1]);
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
        images{i} = imtransform(images{i}, H{i, REF}, 'XData', [xMin xMax], 'YData', [yMin yMax], 'XYScale', [1 1]);
        alphaChannel{i} = imtransform(alphaChannel{i}, H{i, REF}, 'XData', [xMin xMax], 'YData', [yMin yMax], 'XYScale', [1 1]);
    elseif i>REF
        images{i} = imtransform(images{i}, H{REF, i}, 'XData', [xMin xMax], 'YData', [yMin yMax], 'XYScale', [1 1]);
        alphaChannel{i} = imtransform(alphaChannel{i}, H{REF, i}, 'XData', [xMin xMax], 'YData', [yMin yMax], 'XYScale', [1 1]);
    else
        %no transformation, just for having the same output panorama-size
        images{i} = imtransform(images{i},  maketform('projective',eye(3)), 'XData', [xMin xMax], 'YData', [yMin yMax], 'XYScale', [1 1]);
        alphaChannel{i} = imtransform(alphaChannel{i},  maketform('projective',eye(3)), 'XData', [xMin xMax], 'YData', [yMin yMax], 'XYScale', [1 1]);
    end
    
end

%create final alpha mask and combine images to one final panorama
h = size(images{1},1);
w = size(images{1},2);
alphaChannelSum = zeros(h,w);

output = double(zeros(h,w,3));
for i = 1:imagesCount
    output(:,:,1) = output(:,:,1) + double(images{i}(:,:,1)) .* alphaChannel{i};
    output(:,:,2) = output(:,:,2) + double(images{i}(:,:,2)) .* alphaChannel{i};
    output(:,:,3) = output(:,:,3) + double(images{i}(:,:,3)) .* alphaChannel{i};
    
    alphaChannelSum = alphaChannelSum + alphaChannel{i};
end

output(:,:,1) = output(:,:,1) ./ alphaChannelSum;
output(:,:,2) = output(:,:,2) ./ alphaChannelSum;
output(:,:,3) = output(:,:,3) ./ alphaChannelSum;

figure;imshow(uint8(output));


end