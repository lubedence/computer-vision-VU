function [training, group] = BuildKNN(folder, C)

STEPSIZE = 2;
NUM_WORDS = size(C,2); % same as NUM_CLUSTERS in BuildVocabulary

filepaths = ImagePaths(folder);
NUM_IMAGES = length(filepaths);
training = zeros(NUM_IMAGES, NUM_WORDS);
group = zeros(NUM_IMAGES, 1);

wb_handle = waitbar(0, 'Building Feature Representations...');

for i = 1:length(filepaths)
    I = im2single(imread(filepaths{i}.Path));
    group(i) = filepaths{i}.Class;
    
    training(i,:) = ImageWordHistogram(I, C, STEPSIZE, NUM_WORDS);
    
    waitbar(i / NUM_IMAGES);
end

fprintf('feature representations complete!\n');
close(wb_handle);

end