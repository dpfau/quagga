function ROI = connect_components(ROI,overlap)

if ~isempty(ROI)
    X = 1;
    while max(X(:)) > overlap
        X = zeros(length(ROI));
        
        % Get overlap between ROIs
        for i = 1:length(ROI)
            for j = 1:length(ROI)
                if i ~= j
                    X(i,j) = abs(full(dot(vec(ROI{i}),vec(ROI{j}))))/full(dot(vec(ROI{i}),vec(ROI{i})));
                end
            end
        end
        
        % Resolve which component to merge into which
        merge_sets = get_ancestors(X>overlap);
        
        % Merge components
        ROI_ = cell(1,length(merge_sets));
        for i = 1:length(merge_sets)
            ROI_{i} = apply(@plus,ROI{merge_sets{i}});
        end
        ROI = ROI_;
    end
end