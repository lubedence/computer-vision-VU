function [C] = BuildVocabulary(folder, num_clusters)

NUM_FEATURES = 100; % approx. number of sift features per image

filepaths = ImagePaths(folder);
NUM_IMAGES = length(filepaths);
descrs_overall = zeros(128, NUM_FEATURES * NUM_IMAGES);
current_index = 1;

wb_handle = waitbar(0, 'Building Vocabulary...');

for i = 1:length(filepaths)
    I = im2single(imread(filepaths{i}.Path));
    stepsize = sqrt(size(I,1) * size(I,2) / (NUM_FEATURES * 1.2));
    [~, descrs] = vl_dsift(I, 'Step', stepsize, 'Fast');
    % take random subsample of size NUM_FEATURES
    y = randsample(size(descrs,2), NUM_FEATURES);
    descrs_overall(:, current_index:(current_index + NUM_FEATURES - 1)) = descrs(:, y);
    current_index = current_index + NUM_FEATURES;
    waitbar(i / NUM_IMAGES);
end

fprintf('k-means...\n');
[C, ~] = vl_kmeans(single(descrs_overall), num_clusters);

fprintf('vocabulary complete!\n');
close(wb_handle);

end