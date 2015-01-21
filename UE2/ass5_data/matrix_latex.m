for i = 1:8
    for j = 1:8
        fprintf(' & %d', conf_matrix(i,j));
        if i == j
            fprintf(' \\cellcolor[gray]{.8}');
        end
    end
    fprintf(' \\\\\n');
end