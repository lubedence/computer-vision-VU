% I ... image
% K ... number of clusters
% D ... number of features (3 or 5)
% write_out ... write to file (optional)
function ex2(filename, K, D, write_out)

MAX_ITERATIONS = 7;
in_dir = 'res/';
out_dir = 'ex2_out/';

I = im2double(imread(strcat(in_dir, filename))); % read and normalize
N = size(I,1)*size(I,2); % num of pixels

if D ~= 3 && D ~= 5
    disp('D has to be 3 or 5');
    return;
end
u = rand(D,K); % step 1
    
JOld=inf;
J=0;
count = 0;

while count < MAX_ITERATIONS
    disp(JOld - J);
    
    count = count + 1;
    r = false(N,K);
    JOld = J;
    J=0;
    uz = zeros(D,K); % numerator
    un = zeros(1,K); % denominator
    
    for i = 1:size(I,1)
        for j = 1:size(I,2)
            if(D==3)
                px_data = squeeze(I(i,j,:));
            else
                px_data = [squeeze(I(i,j,:)); i/size(I,1); j/size(I,2)];
            end
            diff = repmat(px_data, [1, K]) - u;
            dist = sum(diff.^2);
            [m,arg] = min(dist);
            r((i-1)*size(I,2)+j,arg)=1; % step 2
            uz(:,arg) = uz(:,arg) + px_data;  
            un(arg) = un(arg) +1;
            J = J + m;
        end
    end

    un(un == 0) = 1;
    u = uz./repmat(un, [D,1]); % step 3
end

u % show centroids

% ====================================================
% visualize the results 
% ====================================================

cluster_vec = zeros(size(r,1), D);
for k = 1:K
    for c = 1:3
        cluster_vec(r(:,k), c) = u(c, k);
    end
end

cluster_img = zeros(size(I));
for c = 1:3
    tmp = reshape(cluster_vec(:,c), [size(I,2), size(I,1)]);
    cluster_img(:,:,c) = tmp';
end

fig = figure;
imshow(cluster_img);hold on;
if (D ==5)
    for k = 1:K
        % marker filling shows centroid color
        plot(u(5,k)*size(I,2), u(4,k)*size(I,1), 'o', 'MarkerSize', 6, ...
            'MarkerFaceColor', u(1:3,k), 'MarkerEdgeColor', [0,0,0]);
    end
end
% write to file
if exist('write_out', 'var') && write_out
    filename_out = sprintf('%s%s.K%d.D%d.I%d.png', out_dir, filename, K, D, count);
    saveas(fig, filename_out);
end
hold off;
end