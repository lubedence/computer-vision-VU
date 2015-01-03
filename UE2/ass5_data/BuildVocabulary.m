function [C] = BuildVocabulary(folder, num_clusters)

dir_info = dir(folder);
for i = 1:length(dir_info)
    if dir_info(i).name(1) == '.'
        continue;
    end
    
    subfolder = sprintf('%s/%s', folder, dir_info(i).name);
    subdir_info = dir(subfolder);
    for j = 1:length(subdir_info)
        if subdir_info(j).name(1) == '.'
            continue;
        end
        
        filepath = sprintf('%s/%s', subfolder, subdir_info(j).name);
        I = im2single(imread(filepath));
        stepsize = min(size(I,1), size(I,2)) / num_clusters; % TODO: wrong
        [frames, descrs] = vl_dsift(I, 'Step', stepsize, 'Fast');
    end

end