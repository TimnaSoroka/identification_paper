%% mrmr on data
clear
close all
rng(1500)

load('/Users/worg/Documents/identificationPapar/code/breathMetric_parameters/example_for_same_day_mat.mat');
load('/Users/worg/Documents/identificationPapar/var_names');

zelano_mat(:,7)=[];
zelano_test(:,7)=[];
var_names(7)=[];

for n=1:size(var_names,2)
    var_names{n}=regexprep(var_names{n},'_'," ");
end

method='nca'

 [idx,s]=fscmrmr(zelano_mat,zelano_labels);
% % [i2 ,s2]=fscchi2(zelano_mat,zelano_labels);
  % A=fscnca(zelano_mat,zelano_labels);
  % scores=A.FeatureWeights;
  % [~,idx]=sort(scores,'descend');
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

for i=2:length(idx)
params=[idx(1:i)];

    for perm=1:3
        [mdl, validationAccuracyReal(perm)] = mediumNeuralNetwork(zelano_mat(:,params),zelano_labels);
        labels_hat = mdl.predictFcn(zelano_test(:,params));
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
        acc_id(perm,1)=ac./length(C)*100;
    end
end

save(['acc_id_FS_' method '.mat'],'acc_id');