function create_PCA_doseresponse(conditions,data)
%create_PCA_doseresponse(conditions,data) - this function will create a 2D
%plot showing the two largest principal components. it is meant to take in
%dose-response data and show how dose affects the behavior of the larvae on
%a principal components space

conditions_unique = unique(conditions);
[~, score, ~] = pca(data);
figure();hold on; colors = 'rgbcmyk';
coloridx = 1;
for i = 1:numel(conditions_unique);
    %Find all the indices of the data corresponding to each condition
    temp_idx = strcmp(conditions_unique{i},conditions);
    if coloridx > 6
        coloridx = 1;
    else
        coloridx = coloridx + 1;
    end
    plot(score(temp_idx,1),score(temp_idx,2),[colors(coloridx) 'o']);
end
conditions_legend = strrep(conditions_unique,'_',' ');
legend(conditions_legend,'Location','Best');
title('PCA analysis of varying doses');
xlabel('Principal component 1'); ylabel('Principal component 2');