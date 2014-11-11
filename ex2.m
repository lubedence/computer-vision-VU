% I ... image
% K ... number of clusters
% D ... number of features (3 or 5)
% write_out ... write to file (optional)
function ex2(filename, K, D, write_out)

MAX_ITERATIONS = 20;
THRESHOLD = 1;
in_dir = 'res/';
out_dir = 'ex2_out/';

I = im2double(imread(strcat(in_dir, filename))); % read and normalize
N = size(I,1)*size(I,2); % num of pixels

if D ~= 3 && D ~= 5
    disp('D has to be 3 or 5');
    return;
end
u = rand(D,K); % step 1
    
J = 0;
JOld = inf;
count = 0;

Inew = I;
if D == 5
    Inew(:,:,4) = repmat((1:size(I,1))' ./ size(I,1), [1 size(I,2)]);
    Inew(:,:,5) = repmat((1:size(I,2)) ./ size(I,2), [size(I,1) 1]);
end
Inew = repmat(Inew, [1 1 1 K]);

while count < MAX_ITERATIONS
    if abs(J - JOld) < THRESHOLD
        disp('J - JOld < THRESHOLD');
        break;
    end
    
    count = count + 1;
    JOld = J;
    
    % calculate distances
    diffs = ones(size(I,1), size(I,2), D, K);
    for k = 1:K
        diffs(:,:,:,k) = Inew(:,:,:,k) - repmat(reshape(u(:,k), [1 1 D]), [size(I,1) size(I,2) 1]);
    end
    dists = squeeze(sum(diffs.^2, 3)); % dists size is [size(I,1) size(I,2) K]
    [ms, args] = min(dists, [], 3); % mins of distances
    ks = reshape(args', [1 N]);
    
    % calculate J
    J = sum(sum(ms));
    fprintf('JOld - J = %d\n', JOld - J);
    
    % construct r
    r = false(N, K);
    r_tmp = full(ind2vec(ks))';
    r(1:N, 1:size(r_tmp,2)) = r_tmp;
    
    % calculate u
    for k = 1:K
        xs = zeros(N,D);
        for d = 1:D
            xs(:,d) = reshape(Inew(:,:,d,k)', [N, 1]);
        end
        xs(~r(:,k), :) = 0;
        u(:,k) = sum(xs) ./ sum(r(:,k));
        %fprintf('cluster k: %d\n', sum(r(:,k)));
    end
    
%     for i = 1:size(I,1)
%         for j = 1:size(I,2)
%             if(D==3)
%                 px_data = squeeze(I(i,j,:));
%             else
%                 px_data = [squeeze(I(i,j,:)); i/size(I,1); j/size(I,2)];
%             end
%             diff = repmat(px_data, [1, K]) - u;
%             dist = sum(diff.^2);
%             [m,arg] = min(dist);
%             r((i-1)*size(I,2)+j,arg)=1; % step 2
%             uz(:,arg) = uz(:,arg) + px_data;  
%             un(arg) = un(arg) +1;
%             J = J + m;
%         end
%     end

%    un(un == 0) = 1;
%    u = uz./repmat(un, [D,1]); % step 3
end

fprintf('%d iterations\n', count);
u % show centroids

% ====================================================
% visualize the results 
% ====================================================

function visualize()
    cluster_vec = zeros(N, D);
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
            u(isnan(u)) = 0; % clusters with no elements get the zero centroid
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

visualize();
end

