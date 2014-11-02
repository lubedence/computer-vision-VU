function ex1(bonus)
    if(bonus == 1)
        ex1_bonus();
        return;
    end
    dir = 'res/';
    names = {'00125v', '00149v', '00153v', ...
        '00351v', '00398v', '01112v'};

    rn = '_R.jpg';
    gn = '_G.jpg';
    bn = '_B.jpg';

    for k = 1:length(names)
        R = readimg(dir, names{k}, rn);
        G = readimg(dir, names{k}, gn);
        B = readimg(dir, names{k}, bn);

        s1 = ncc(R, G);
        s2 = ncc(R, B);

        G = circshift(G, s1);
        B = circshift(B, s2);

        I = R;
        I(:, :, 2) = G;
        I(:, :, 3) = B;

        imwrite(I, strcat(names{k}, '.png'));
    end
end

function ex1_bonus()
    dir = 'highres/';
    names = {'img1'};

    rn = '_1.jpg';
    gn = '_2.jpg';
    bn = '_3.jpg';

    for k = 1:length(names)
        R = readimg(dir, names{k}, rn);
        G = readimg(dir, names{k}, gn);
        B = readimg(dir, names{k}, bn);

        G = ncc_bonus(R, G, 8);
        B = ncc_bonus(R, B, 8);
        I = R;
        I(:, :, 2) = G;
        I(:, :, 3) = B;

        imwrite(I, strcat(names{k}, '.png'));
    end
end

function [I] = readimg(dir, name, ext)
    I = imread(strcat(dir, strcat(name, ext)));
end

function [s, maxcorr] = ncc(I1, I2)
    maxcorr = 0;
    s = [0 0];
    for i = -15:15
        for j = -15:15
            I2tmp = circshift(I2, [i j]);
            corr = corr2(I1(15:(end-15), 15:(end-15)), I2tmp(15:(end-15), 15:(end-15))); % this is great
            if corr > maxcorr
                maxcorr = corr;
                s = [i j];
            end
        end
    end
end

function [I2] = ncc_bonus(I1, I2, resize)

    I1_res = imresize(I1, [(size(I1,1)/resize) NaN]);
    I2_res = imresize(I2, [(size(I2,1)/resize) NaN]);
    maxcorr = 0;
    s = [0 0];
    for i = -2*resize:2*resize
        for j = -2*resize:2*resize
            I2tmp = circshift(I2_res, [i j]);
            corr = corr2(I1_res(15:(end-15), 15:(end-15)), I2tmp(15:(end-15), 15:(end-15))); % this is great
            if corr > maxcorr
                maxcorr = corr;
                s = [i j];
            end
        end
    end
    
    I2 = circshift(I2, s*resize);
    disp(s);
    if(resize>1)
        ncc_bonus(I1, I2, resize/2);
    end
end