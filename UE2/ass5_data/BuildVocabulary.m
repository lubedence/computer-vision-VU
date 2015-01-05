function [C] = BuildVocabulary(folder, num_clusters)

NUM_FEATURES = 100; % approx. number of sift features per image
NUM_IMAGES = 800;

descrs_overall = zeros(128, NUM_FEATURES * NUM_IMAGES);
current_index = 1;

dir_info = dir(folder);
for i = 1:length(dir_info)
    if dir_info(i).name(1) == '.'
        continue;
    end
    
    subfolder = sprintf('%s/%s', folder, dir_info(i).name);
    fprintf('entering %s...\n', subfolder);
    subdir_info = dir(subfolder);
    for j = 1:length(subdir_info)
        if subdir_info(j).name(1) == '.'
            continue;
        end
        
        filepath = sprintf('%s/%s', subfolder, subdir_info(j).name);
        I = im2single(imread(filepath));
        stepsize = sqrt(size(I,1) * size(I,2) / (NUM_FEATURES * 1.2));
        [frames, descrs] = vl_dsift(I, 'Step', stepsize, 'Fast');
        % take random subsample of size NUM_FEATURES
        y = randsample(size(descrs,2), NUM_FEATURES);
        descrs_overall(:, current_index:(current_index + NUM_FEATURES - 1)) = descrs(:, y);
        current_index = current_index + NUM_FEATURES;
    end
end

fprintf('k-means...\n');
[C, A] = vl_kmeans(single(descrs_overall), num_clusters);

fprintf('vocabulary complete!\n\n');

end