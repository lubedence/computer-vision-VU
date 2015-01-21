function [conf_matrix] = ClassifyImages(folder, C, training, group)

STEPSIZE = 2;
NUM_WORDS = size(C,2); % same as NUM_CLUSTERS in BuildVocabulary
K = 3;
CLASSES = 1:8;

filepaths = ImagePaths(folder);
NUM_IMAGES = length(filepaths);
test = zeros(NUM_IMAGES, NUM_WORDS);
class_correct = zeros(NUM_IMAGES, 1);

wb_handle = waitbar(0, 'Classifying...');

for i = 1:length(filepaths)
    I = im2single(imread(filepaths{i}.Path));
    class_correct(i) = filepaths{i}.Class;
    
    test(i,:) = ImageWordHistogram(I, C, STEPSIZE, NUM_WORDS);
    
    waitbar(i / NUM_IMAGES);
end

class = knnclassify(test, training, group, K);
conf_matrix = confusionmat(class_correct, class, 'order', CLASSES);
correct_ratio = sum(diag(conf_matrix)) / sum(sum(conf_matrix));
fprintf('correctly classified: %.2f%%\n', correct_ratio * 100);

fprintf('classification complete!\n');

close(wb_handle);

end