% I ... image
% K ... number of clusters
% D ... number of features (3 or 5)
% write_out ... write to file (optional)
function ex2(filename, K, D, write_out)

MAX_ITERATIONS = 20; % just to make sure, that the algorithm terminates
THRESHOLD = 1; %used for the difference between J and JOld (previous iteration)
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
JOld = inf; %J from previous iteration
count = 0;

data = zeros(N, D);
data(:, 1) = reshape(I(:,:,1)', [N 1]);
data(:, 2) = reshape(I(:,:,2)', [N 1]);
data(:, 3) = reshape(I(:,:,3)', [N 1]);
[is, js] = find(ones(size(I(:,:,1))));
if D == 5
    data(:, 4) = is ./ size(I, 1);
    data(:, 5) = js ./ size(I, 2);
end
data = repmat(data, [1 1 K]);

while count < MAX_ITERATIONS %could be removed
    if abs(J - JOld) < THRESHOLD
        %disp('J - JOld < THRESHOLD');
        break;
    end
    
    count = count + 1;
    JOld = J;
    
    % calculate differences between pixels and cluster-centers 
    diffs = zeros(N,D,K);
    dists = zeros(N,K);
    for k = 1:K
        diffs(:,:,k) = data(:,:,k) - repmat(u(:,k)', [N, 1]); % difference
        dists(:,k) = sum(diffs(:,:,k).^2, 2); % distance
    end
    [mins, k_mins] = min(dists, [], 2); % search for min distances
    
    % calculate J
    J = sum(sum(mins));
    fprintf('JOld - J = %d\n', JOld - J);
    
    % construct r (each pixel gets assigned to the cluster with the lowest
    % distance)
    r = false(N, K);
    r_tmp = full(ind2vec(k_mins'))';
    r(1:N, 1:size(r_tmp,2)) = r_tmp;
    
    % calculate u (new cluster centroids)
    for k = 1:K
        xs = data(:,:,k);
        xs(~r(:,k), :) = 0;
        u(:,k) = sum(xs(:,:)) ./ sum(r(:,k));
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

    %color all pixels of a cluster with their mean color values
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

