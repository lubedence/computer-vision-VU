function ex2(I, K, D)

MAX_ITERATIONS = 8;

%u = rand(5,k).*repmat([255,255,255,size(I,1),size(I,2)]',[1 k]);
I = im2double(I);
N = size(I,1)*size(I,2);
if (D==3)
    u = rand(3,K);
else if(D==5)
    u = rand(5,K);
    else 
    disp('D has to be 3 or 5');
    return;
    end
end
    
    
JOld=inf;
J=0;
count = 0;

while(count < MAX_ITERATIONS)
    
    disp(JOld - J);
    
    count = count + 1;
    r = false(N,K);
    JOld = J;
    J=0;
    uz = zeros(D,K);
    un = zeros(1,K);
    
    for i = 1:size(I,1)
        for j = 1:size(I,2)
            if(D==3)
                diff = repmat(squeeze(I(i,j,:)), [1, K]) - u;
            else              
                diff = repmat([squeeze(I(i,j,:));i/size(I,1);j/size(I,2)], [1, K]) - u;
            end
            dist = sum(diff.^2);
            [m,arg] = min(dist);
            r((i-1)*size(I,2)+j,arg)=1;
            J = J + m;
            if(D ==3)
                uz(:,arg) = uz(:,arg) + squeeze(I(i,j,:));
            else
                uz(:,arg) = uz(:,arg) + [squeeze(I(i,j,:));i/size(I,1);j/size(I,2)];
            end     
            un(arg) = un(arg) +1;
        end
    end

    un(un == 0) = 1;
    u = uz./repmat(un, [D,1]);
end

% visualize the results

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
figure; 
imshow(cluster_img);hold on;
if (D ==5)
    for k = 1:K
        plot(  u(5,k)*size(I,2),u(4,k)*size(I,1), 'bo');
    end    
end
hold off;
end