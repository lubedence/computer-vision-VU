function ex1whAlign(with_pyramid, highres)
    out_dir = 'ex1_merge/';
    
    if highres
        dir = 'highres/';
        names = {'img1'};
    else
        dir = 'res/';
        names = {'00125v', '00149v', '00153v', ...
            '00351v', '00398v', '01112v'};
    end

    rn = '_R.jpg';
    gn = '_G.jpg';
    bn = '_B.jpg';

    for k = 1:length(names)
        R = imread(makepath(dir, names{k}, rn));
        G = imread(makepath(dir, names{k}, gn));
        B = imread(makepath(dir, names{k}, bn));
        
        tic;
        if with_pyramid
            %pyramidSize = floor( log2(sqrt(length(R(:)))/200) )+1;
            %s1 = ncc(R, G, pyramidSize);
            %s2 = ncc(R, B, pyramidSize);
        else
            %s1 = ncc(R, G, 1);
            %s2 = ncc(R, B, 1);
        end
        
        fprintf('----------------------------------------\n');
        fprintf('Image %d time: %d \n', k, toc);
        fprintf('----------------------------------------\n');
        
        %G = circshift(G, s1);
        %B = circshift(B, s2);

        I = R;
        I(:, :, 2) = G;
        I(:, :, 3) = B;

        imwrite(I, makepath(out_dir, names{k}, '.png'));
    end
end


function [s, maxcorr] = ncc(I1, I2, level)
    maxcorr = 0;
    raster = max(ceil(15/level), 2); %size of search raster +-raster %TODO: eliminate constant 15
    %raster = ceil(15 / ( log2(sqrt(length(I1(:)))/200)+1));
    border = ceil(size(I1,2) *0.15); % 15%border of image width
    
    sOld = [0 0];
    if(level > 1)
        sOld = ncc(impyramid(I1, 'reduce'), impyramid(I2, 'reduce'), level-1);
    end
    
    fprintf('Level: %d %dx%d\n', level, size(I1,1), size(I1,2));
    fprintf('Border size: %d\n', border);
    fprintf('Raster size(+-): %d\n', raster);
    fprintf('Previous shift: %d|%d\n\n', sOld);
     
    for i = -raster:raster
        for j = -raster:raster
            I2tmp = circshift(I2(:,:), [i j] + sOld*2);
            corr = corr2(I1(border:(end-border), border:(end-border)), I2tmp(border:(end-border), border:(end-border))); % this is great
            if corr > maxcorr
                maxcorr = corr;
                s = [i j];
            end
        end
    end
    s = s + sOld*2;
end

%function [s, maxcorr] = ncc(I1, I2)
%    maxcorr = 0;
%    s = [0 0];
%    for i = -15:15
%        for j = -15:15
%            I2tmp = circshift(I2, [i j]);
%            corr = corr2(I1(15:(end-15), 15:(end-15)), I2tmp(15:(end-15), 15:(end-15))); % this is great
%            if corr > maxcorr
%                maxcorr = corr;
%                s = [i j];
%            end
%        end
%    end
%end

function [path] = makepath(dir, name, ext)
    path = strcat(dir, strcat(name, ext));
end
