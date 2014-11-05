function ex2(I, K, f)

%u = rand(5,k).*repmat([255,255,255,size(I,1),size(I,2)]',[1 k]);
I = im2double(I);
N = size(I,1)*size(I,2);

u = rand(3,K);
JOld=inf;
J=0;
count = 0;
while( count<7)
    
    disp(JOld - J);
    
    count = count + 1;
    r = false(N,K);
    JOld = J;
    J=0;
    uz = zeros(3,K);
    un = zeros(1,K);
    
    for i = 1:size(I,1)
        for j = 1:size(I,2)

            diff = repmat(squeeze(I(i,j,:)), [1, K]) - u;
            dist = sum(diff.^2);
            [m,arg] = min(dist);

            r((i-1)*size(I,2)+j,arg)=1;
            J = J + m;
            uz(:,arg) = uz(:,arg) + squeeze(I(i,j,:));
            un(arg) = un(arg) +1;
        end
    end

    un(un == 0) = 1;
    u = uz./repmat(un, [3,1]);
end


cluster_img = zeros(size(r,1), 3);
for l = 1:K
    cluster_img(r(:,l),1) = u(1,l);
    cluster_img(r(:,l),2) = u(2,l);
    cluster_img(r(:,l),3) = u(3,l);
end
R = reshape(cluster_img(:,1), [size(I, 1), size(I, 2)]);
G = reshape(cluster_img(:,2), [size(I, 1), size(I, 2)]);
B = reshape(cluster_img(:,3), [size(I, 1), size(I, 2)]);
cluster_img = zeros(size(I,1),size(I,2),3);
cluster_img(:,:,1) = R;
cluster_img(:,:,2) = G;
cluster_img(:,:,3) = B;
figure;imshow(cluster_img);



end