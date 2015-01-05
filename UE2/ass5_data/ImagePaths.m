function [paths] = ImagePaths(folder)
% iterate over all subdirectories and return the full file paths and
% class names

paths = {};
k = 1;

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
        paths{k}.Path = filepath;
        paths{k}.Class = i;
        %paths{k}.ClassName = dir_info(i).name;
        k = k + 1;
    end
end

end