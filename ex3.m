function ex3(filename)

sigma_0 = 2;
k = 1.25;
levels = 10;
in_dir = 'res/';
out_dir = 'ex3_out/';
I = im2double(imread(strcat(in_dir, filename)));
scale_space = zeros(size(I,1), size(I,2), levels);

function [f] = level_filter(lvl)
    % as suggested in the hints
    sig_ = sigma_0 * k^lvl;
    f = fspecial('log', 2*floor(3*sig_)+1, sig_) * sig_^2;
end

for lvl = 1:levels
    %figure; surf(level_filter(lvl));
    scale_space(:,:,lvl) = imfilter(I, level_filter(lvl), 'same', 'replicate');
end

for lvl = 2:(levels-1)
    % step 2
end

end