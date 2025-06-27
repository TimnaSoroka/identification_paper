function [V1_sorted, V2_sorted, common_labels] = sort_vectors_by_labels(V1, L1, V2, L2)
    % Ensure column vectors
    L1 = L1(:);
    L2 = L2(:);
    V1 = V1(:);
    V2 = V2(:);

    % Find common labels
    [common_labels, idx1, idx2] = intersect(L1, L2, 'stable');

    if isempty(common_labels)
        error('No matching labels found between the two sets.');
    end

        if numel(unique(L2)) ~= numel(L2)
        error('Duplicate labels found in L2.');
    end

    % Sort V1 and V2 to match the common labels
    V1_sorted = V1(idx1);
    V2_sorted = V2(idx2);
end
