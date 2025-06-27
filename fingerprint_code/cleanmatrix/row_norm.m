function norms_vec = row_norm(mat)
%ROW_NORM Summary of this function goes here
%   Detailed explanation goes here
% Slightly faster than vec_norm based on 100 runs of 100*1000

    norms_vec = sqrt(sum(mat.^2, 2));
end

