%% mrmr on data
clear
close all
rng(1500)

load('/Users/worg/Documents/identificationPapar/code/breathMetric_parameters/example_for_same_day_mat.mat');
load('/Users/worg/Documents/identificationPapar/var_names');
X=[zelano_mat;zelano_test];
X(:,7)=[];
var_names(7)=[];
ii=0;
while ii<size(X,2)
ii=ii+1;
for i=1:size(X,2)
    C(i)=corr(X(:,ii),(X(:,i)));
end

A=C>abs(0.7);
B=(C>0.99);
D=A-B;
X(:,logical(D))=[];
var_names(logical(D))=[];
clearvars A B C D
end

for n=1:size(var_names,2)
    var_names{n}=regexprep(var_names{n},'_'," ");
end

nFeatures = 24;

for ii=24; %[5,10,15,20]
combinationSize = ii;

% Generate all possible combinations of 5 parameters from 24 features
combinations = nchoosek(1:nFeatures, combinationSize);



for i=1:30
params=[combinations(randperm(size(combinations,1),1),:)];
par{i}=params;
    for perm=1
        [mdl, validationAccuracyReal(perm)] = mediumNeuralNetwork(zelano_mat(:,params),zelano_labels);
        labels_hat = mdl.predictFcn(zelano_test);
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

save(['acc_id_FS_' num2str(ii) 'params_all_combinations.mat'],'acc_id','par');
end