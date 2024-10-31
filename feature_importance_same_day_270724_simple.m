%% mrmr on data
clear
close all
rng('default')

load('/Users/worg/Documents/identificationPapar/code/breathMetric_parameters/example_for_same_day_mat.mat');
load('/Users/worg/Documents/identificationPapar/var_names');

zelano_mat(:,7)=[];
zelano_test(:,7)=[];
var_names(7)=[];

for n=1:size(var_names,2)
    var_names{n}=regexprep(var_names{n},'_'," ");
end


  [idx,s]=fscmrmr(zelano_mat,zelano_labels);
% % [i2 ,s2]=fscchi2(zelano_mat,zelano_labels);
% A=fscnca(zelano_mat,zelano_labels);
% scores=A.FeatureWeights;
% 
% figure
% bar(zscore(scores))
% hold on
% bar(zscore(s))
% set(gca,'FontSize',15)
% xticks(1:25)
% xticklabels(var_names)
% xlabel('Parameters')
% ylabel('Score (normalized)')
% legend({'NCA','MRMR'})

for i=1:length(idx)
params=[idx(1):idx(i)];

    for perm=1:3
predictors = zelano_mat(:,1); %inputTable(:, predictorNames);
response = zelano_labels;
% isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];

% Train a classifier
% This code specifies all the classifier options and trains the classifier.
ClassNames= unique(response);
% Train a classifier
classificationNeuralNetwork = fitcnet(...
    predictors, ...
    response, ...
    'LayerSizes', 300, ... %500
    'Activations', 'relu', ...
    'Lambda', 0, ...
    'IterationLimit', 1000, ...
    'Standardize', true, ... 
     'ClassNames',ClassNames);

        k(zelano_mat(:,1),zelano_labels);
        labels_hat = mdl.predictFcn(zelano_test(:,1));
        C = confusionmat(zelano_testing_labels,labels_hat);
        %confusionchart(zelano_testing_labels,labels_hat);
        acc(perm)=sum(diag(C))./sum(C(:));
        ac=0;

        for row=1:length(C)
            prc=C(row,:)/sum(C(row,:));
            [prc_sorted,idx_sorted]=sort(prc,'descend');
            %    if prc_sorted(1)-prc_sorted(2)>0.1
            if idx_sorted(1)==row
                ac=ac+1;
            end

        end
        acc_id(perm,i)=ac./length(C)*100;
    end
end