function ex3(filename, threshold, scaletest)
% filename: only the file name, directory is fixed
% threshold: for example 0.2
% scaletest: set 1 to additionally use half-sized image

in_dir = 'res/';
out_dir = 'ex3_out/';

[scale_space, Result] = blob_det(filename);
if scaletest
    % resize image and save with 'half_' prefix
    name_half = sprintf('half_%s', filename);
    I_tmp = imread(strcat(in_dir, filename));
    imwrite(imresize(I_tmp, 0.5), strcat(in_dir, name_half));
    [scale_space_half, Result_half] = blob_det(name_half);
    
    % plot responses for both images for a common key point
    % first_common_index = find(Result(:,:,1) & Result_half(:,:,1));
    % TODO how can we find the same keypoint in both images?
end

function [scale_space, Result] = blob_det(filename)
    tic;

    sigma_0 = 2;
    k = 1.25;
    levels = 10;
    
    I = im2double(imread(strcat(in_dir, filename)));
    Result = zeros(size(I,1), size(I,2), 2);
    scale_space = zeros(size(I,1), size(I,2), levels);
    scale_space_max = zeros(size(scale_space));

    if size(I,3) > 1
        error('image has more than one color channel');
    end
    
    disp(filename);

    function [f] = level_filter(lvl)
        % create the filter for a single level
        % as suggested in the hints
        sig_ = sigma_0 * k^lvl;
        f = fspecial('log', 2*floor(3*sig_)+1, sig_) * sig_^2;
    end

    for lvl = 1:levels
        % filter the image with the corresponding kernel
        scale_space(:,:,lvl) = abs(imfilter(I, level_filter(lvl), 'same', 'replicate'));

        % calculate the maxima of all 3x3 windows of the image
        scale_space_max(:,:,lvl) = imdilate(scale_space(:,:,lvl), ones(3,3));
        %scale_space_max(:,:,lvl) = ordfilt2(scale_space(:,:,lvl),9,ones(3,3));
    end

    for lvl = 2:(levels-1)
        for i = 2:(size(I,1)-1)
            for j = 2:(size(I,2)-1)
                current_px = scale_space(i,j,lvl);
                % check threshold
                if current_px < threshold
                    continue;
                end

                max_prev = scale_space_max(i,j,lvl-1);
                max_next = scale_space_max(i,j,lvl+1);
                max_current = scale_space_max(i,j,lvl);

                % compare value with previous and next levels
                if current_px == max_current && current_px > max_prev && current_px > max_next
                    if current_px > Result(i,j,1)
                        Result(i,j,1) = current_px; % store pixels
                        Result(i,j,2) = sigma_0 * k^lvl * sqrt(2); % store radius
                    end

                end
            end
        end
    end

    % visualize
    [cy, cx] = find(Result(:,:,2)); % get position vectors
    Result2 = Result(:,:,2);
    radii = Result2(sub2ind(size(Result2), cy, cx)); % get radius vector for positions
    fig = figure;
    show_all_circles(I, cx, cy, radii);
    saveas(fig, strcat(out_dir, filename));

    toc
end

end
