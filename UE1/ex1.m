% with_pyramid ... enable pyramid mode
% highres ... work with high resolution files
function ex1(with_pyramid, highres)
    out_dir = 'ex1_out/';
    
    if highres
        dir = 'res/highres/';
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
        
        tic; %stop time
        if with_pyramid
            %get numbers of pyramid levels, logarithmic function - linear
            %would generate too many for large images.
            pyramidSize = floor( log2(sqrt(length(R(:)))/200) )+1;
            s1 = ncc(R, G, pyramidSize);
            s2 = ncc(R, B, pyramidSize);
        else
            s1 = ncc(R, G, 1);
            s2 = ncc(R, B, 1);
        end
        
        %time needed for the shift computation of both channels
        fprintf('----------------------------------------\n');
        fprintf('Image %d time: %d \n', k, toc);
        fprintf('----------------------------------------\n');
        
        G = circshift(G, s1);
        B = circshift(B, s2);

        I = R;
        I(:, :, 2) = G;
        I(:, :, 3) = B;

        imwrite(I, makepath(out_dir, names{k}, '.png'));
    end
end


function [s, maxcorr] = ncc(I1, I2, level)
    maxcorr = 0;
    %linear function for raster-size depending on pyramid level
    raster = max(ceil(15/level), 2); %size of search raster +-raster
    
    %log function for raster-size depending on pyramid level
    %raster = ceil(15 / ( log2(sqrt(length(I1(:)))/200)+1));
    
    %border = 15% of image width. Reduces computation + ignores film artefacts
    border = ceil(size(I1,2) *0.15); 
    
    sOld = [0 0];
    if(level > 1)
        sOld = ncc(impyramid(I1, 'reduce'), impyramid(I2, 'reduce'), level-1);
    end
    
    fprintf('Level: %d %dx%d\n', level, size(I1,1), size(I1,2));
    fprintf('Border size: %d\n', border);
    fprintf('Raster size(+-): %d\n', raster);
    fprintf('Previous shift: %d|%d\n\n', sOld);
    
    %compute NCC for every pixel(i,j) in the search raster 
    for i = -raster:raster
        for j = -raster:raster
            I2tmp = circshift(I2(:,:), [i j] + sOld*2); %shift channel by [i j] and if working with pyramids, by the shift of the previous level (*2 needed for the 2 times larger image)
            corr = corr2(I1(border:(end-border), border:(end-border)), I2tmp(border:(end-border), border:(end-border))); % ignore image border 
            if corr > maxcorr
                maxcorr = corr;
                s = [i j];
            end
        end
    end
    s = s + sOld*2;
end

function [path] = makepath(dir, name, ext)
    path = strcat(dir, strcat(name, ext));
end
