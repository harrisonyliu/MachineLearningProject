function setPCAcolor(color, plotHandles, col_marker, col_line, linewidth)

if size(color,1) == 1
    color = repmat(color,size(plotHandles,1),1);
end

for i = 1:size(plotHandles,1)
    set(plotHandles{i,col_line},'Color',color(i,:),'LineWidth',linewidth);
    for j = 1:size(plotHandles{i,1})
        temp = plotHandles{i,col_marker};
        set(temp{j},'MarkerFaceColor',color(i,:));
    end
end