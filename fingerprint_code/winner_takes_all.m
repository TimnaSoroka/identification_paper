function [correctPredictions,correctnes_column, confidence_level1,confidence_level2] = winner_takes_all(conf_matrix)
    total_samples = sum(conf_matrix,2);
    
    % Compute the number of successes (sum of max values per row)
    [row_max,firstGuess] = max(conf_matrix, [], 2); % Max value per row
  trueClass=1:size(conf_matrix,1);
  correctnes_column=diag(firstGuess==trueClass);
   correctPredictions=sum(correctnes_column);
    confidence_level1=(row_max./total_samples)*100;
    
sortedConfMat = sort(conf_matrix, 2,'descend'); 
secondBest = sortedConfMat(:,2);
    confidence_level2=(secondBest./total_samples)*100;
end
