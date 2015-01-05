function [training, group] = BuildKNN(folder, C)

STEPSIZE = 2;
NUM_IMAGES = 800;
NUM_WORDS = size(C,2); % same as NUM_CLUSTERS in BuildVocabulary

training = zeros(NUM_IMAGES, NUM_WORDS);
group = zeros(NUM_IMAGES, 1);
filepaths = ImagePaths(folder);

wb_handle = waitbar(0, 'Building Feature Representations...');

for i = 1:length(filepaths)
    I = im2single(imread(filepaths{i}.Path));
    group(i) = filepaths{i}.Class;
    
    % find words
    [~, descrs] = vl_dsift(I, 'Step', STEPSIZE, 'Fast');
    nearest_words = knnsearch(C', single(descrs'));
    % make histogram
    training(i,:) = histc(nearest_words, 1:NUM_WORDS);
    % normalize histogram
    training(i,:) = training(i,:) / max(training(i,:));
    
    waitbar(i / NUM_IMAGES);
end

fprintf('feature representations complete!\n\n');
close(wb_handle);

end