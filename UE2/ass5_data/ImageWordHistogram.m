function [h] = ImageWordHistogram(I, C, stepsize, num_words)

% find words
[~, descrs] = vl_dsift(I, 'Step', stepsize, 'Fast');
nearest_words = knnsearch(C', single(descrs'));
% make histogram
h = histc(nearest_words, 1:num_words);
% normalize histogram
h = h / max(h);

end