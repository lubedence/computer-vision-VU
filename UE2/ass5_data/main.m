tic;
C = BuildVocabulary('train', 50);
toc;

tic;
[training, group] = BuildKNN('train', C);
toc;

tic;
conf_matrix = ClassifyImages('test', C, training, group);
toc;