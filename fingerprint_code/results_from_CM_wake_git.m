function results_from_CM_wake_git()

wake_accuracy=[];
numParticipants = 97;
numBlocks = 8;
classificationResults = zeros(numParticipants, numBlocks);
confidenceResults = -50*ones(numParticipants, numBlocks-1);

load('result_BM_same_day/acc_id_BM_wake_5min_blocks_0.65_60min_97.mat')
[correctPredictions,correctnes_column, confidence_level1,confidence_level2] = winner_takes_all(C);
classificationResults(correctnes_column, 1) = 1;
confidenceResults(correctnes_column, 1) = confidence_level1(correctnes_column)-confidence_level2(correctnes_column);
wake_accuracy=[wake_accuracy;correctPredictions];


load('result_BM_same_day/acc_id_BM_wake_5min_blocks_0.65_120min_97.mat')
[correctPredictions,correctnes_column, confidence_level1,confidence_level2] = winner_takes_all(C);
classificationResults(correctnes_column, 2) = 1;
confidenceResults(correctnes_column, 2) = confidence_level1(correctnes_column)-confidence_level2(correctnes_column);

wake_accuracy=[wake_accuracy;correctPredictions];

load('result_BM_same_day/acc_id_BM_wake_5min_blocks_0.65_180min_97.mat')
[correctPredictions,correctnes_column, confidence_level1,confidence_level2] = winner_takes_all(C);
classificationResults(correctnes_column, 3) = 1;
confidenceResults(correctnes_column, 3) = confidence_level1(correctnes_column)-confidence_level2(correctnes_column);

wake_accuracy=[wake_accuracy;correctPredictions];

load('result_BM_same_day/acc_id_BM_wake_5min_blocks_0.65_360min_97.mat')
[correctPredictions,correctnes_column, confidence_level1,confidence_level2] = winner_takes_all(C);
classificationResults(correctnes_column, 4) = 1;
confidenceResults(correctnes_column, 4) = confidence_level1(correctnes_column)-confidence_level2(correctnes_column);

wake_accuracy=[wake_accuracy;correctPredictions];

% load('acc_id_zelano_wake_5min_blocks_0.65_100min_no_overlap_97wake_capped.mat')
% [correctPredictions,correctnes_column, confidence_level1,confidence_level2] = winner_takes_all(C);
% classificationResults(correctnes_column, 5) = 1;
% confidenceResults(correctnes_column, 5) = confidence_level1(correctnes_column)-confidence_level2(correctnes_column);

wake_accuracy=[wake_accuracy;correctPredictions];

load('result_BM_same_day/acc_id_BM_wake_5min_blocks_0.65_540min_97.mat')
[correctPredictions,correctnes_column, confidence_level1,confidence_level2] = winner_takes_all(C);
classificationResults(correctnes_column, 6) = 1;
confidenceResults(correctnes_column, 6) = confidence_level1(correctnes_column)-confidence_level2(correctnes_column);

wake_accuracy=[wake_accuracy;correctPredictions];

load('result_BM_same_day/acc_id_BM_wake_5min_blocks_0.65_100min_97.mat')
[correctPredictions,correctnes_column, confidence_level1,confidence_level2] = winner_takes_all(C);
classificationResults(correctnes_column, 7) = 1;
confidenceResults(correctnes_column, 7) = confidence_level1(correctnes_column)-confidence_level2(correctnes_column);

wake_accuracy=[wake_accuracy;correctPredictions];

load('result_BM_same_day/acc_id_BM_wake_5min_blocks_0.65_100min_rand_97_10-Jun-2025 22:55:36.mat')
[correctPredictions,correctnes_column, confidence_level1,confidence_level2] = winner_takes_all(C);
classificationResults(correctnes_column, 8) = 1;
%confidenceResults(correctnes_column, 7) = confidence_level1(correctnes_column);

save('result_BM_same_day/wake_classification_accuracy.mat','wake_accuracy');

cmap=[0.85 0.85 0.85; 0.5 0.75 1];

% Visualize using imagesc
%f=figure('Color',[1 1 1],'Position',[440 287 300 411]);
imagesc(classificationResults);
colormap(cmap); % Red for incorrect (0), Green for correct (1)
%colorbar;
%title('Classification Results Visualization');
xticks(1:numBlocks);
xticklabels({'60','120','180','360','capped','540','Full','Rand'});
set(gca,'FontSize',12)
xlabel('Minutes');
ylabel('Participants #');
yticks(0:10:numParticipants);
yticklabels(0:10:numParticipants);
end
% Visualize using imagesc
% figure;
% imagesc(confidenceResults);
% colormap("parula"); % Red for incorrect (0), Green for correct (1)
% colorbar;
% %title('Classification Results Visualization');
% xticks(1:numBlocks);
% xticklabels({'60','120','180','360','capped','540','Full','Rand'});
% 
% xlabel('Minutes');
% ylabel('Participants #');
% yticks(1:10:numParticipants);
% yticklabels(1:10:numParticipants);
% grid on;
% 
% 
% load('acc_id_zelano_wake_5min_blocks_0.65_100min_no_overlap_97.mat')
% 
% cmap=[linspace(1,0,256)',linspace(1,0,256)', ones(256,1)];
% confMatPercentage = 100 * (C ./ sum(C, 2));
% 
% figure
% imagesc(confMatPercentage)
% colormap(cmap)
% colorbar;
% c=colorbar;
% c.Label.String ='Accuracy (%)' ;
% [num_successes, num_failures, accuracy] = winner_takes_all(C);
% xlabel('Predicted Participants #');
% ylabel('True Participants    #');
% set(gca,'FontSize',12)
% 
% 
% 
% 
% 
