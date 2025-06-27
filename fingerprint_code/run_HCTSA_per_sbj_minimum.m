function run_HCTSA_per_sbj_minimum(parameters,AllSubjData,directory,WSA,normalize,overlap,cleaning,block_length,train_by_hours,prc_train,timings,start)

normalize=false;
overlap=false;
s=max(size(parameters));
%% 
% load('/Users/timnas/Documents/projects/24h_recordings/NC_24Hours_Analysis/AllSubjData_175.mat')
% directory='/Users/timnas/Documents/projects/identification paper/identification_same day/idwntification_same_day_zelano/code/';
% 
% WSA='wake';
% normalize= false;
% overlap= true;
% cleaning=true;
% 
% block_length=5;
% 
% %% choose subjects:
% subject_to_use=importdata('/Users/timnas/Documents/projects/ADHD/SubjectsToUse.xlsx');
% subject_to_use=subject_to_use.all_subj;
% 
% subjectsNamesToRemoveFromNasalCycleAnalysis=setdiff({AllSubjData.Name},subject_to_use);
% % subjectsNamesToRemoveFromNasalCycleAnalysis = setdiff({allAnalysisFields(strcmp({allAnalysisFields.Group}, 'ADHD')).SubjectName}, 'AKS229_rit1');
% subjectsIndicesToRemoveFromNasalCycleAnalysis = cellfun(@(str) any(strcmp(str, subjectsNamesToRemoveFromNasalCycleAnalysis)), {AllSubjData.Name});
% AllSubjData = AllSubjData(~subjectsIndicesToRemoveFromNasalCycleAnalysis);

%%
% if train_by_hours
%     How_long_to_train=0.6*60;
%     How_long_to_test=1*60;
%     StartPoint_in_minutes=1;
%     StartPoint=StartPoint_in_minutes*60*6;
%     How_long_train=How_long_to_train*60*6;
%     How_long_test=How_long_to_test*60*6;
% end

rng(1)

for iii=1:length(timings)
    training_mat=[];
training_labels=[];
testing_mat=[];
testing_labels=[];


time_to_check=timings(iii);
    time_in_blocks=round(time_to_check/block_length);   


for i=1:size(AllSubjData,2)
    subjData=AllSubjData(i);
    SubjectName=subjData.Name;
% if normalize
if strcmpi('wake',WSA)
file=dir([directory '/HCTSA/mat_files_250/' SubjectName '/HCTSA_' SubjectName '_' WSA '_5min_new1.mat']);
 else
 file=dir([directory '/HCTSA/HCTSA_sleep/' SubjectName '/HCTSA_'  SubjectName '_' WSA '_5min_1.mat']);
 end

 if isempty(file)
     fprintf('!')
 end

load([file.folder '/' file.name]);

% if size(mat)~=size(measureResults)
%     fprintf('check %s\n', SubjectName)
% end
% 
% [mat.Nostril_Corr_RValue]=measureResults.Nostril_Corr_RValue;
% [mat.Nostril_Corr_PValue]=measureResults.Nostril_Corr_PValue;
% [mat.MeanAmplitudeLI]=measureResults.MeanAmplitudeLI;
% [mat.MeanLateralityIndex]=measureResults.MeanLateralityIndex;
% [mat.stdAmplitudeLI]=measureResults.stdAmplitudeLI;
% [mat.stdLateralityIndex]=measureResults.stdLateralityIndex;

if overlap
    o=1:block_length;
else
o=1;
end

for ii=1:length(o)
%x=struct2table(mat(:,ii));
Data_per_subject=TS_DataMat;
labels=TimeSeries.Keywords;
% table2array(x);

if size(Data_per_subject,1)-start<start+time_in_blocks
            % all_values(sbj,:)=deal(nan);
            fprintf('subject %s were wake only %f hours, hence excluded here \n', SubjectName,(size(Data_per_subject,1)*5)/60 )
        elseif time_to_check==100
                D=Data_per_subject;
                L=labels;

               
                stop=round(prc_train*size(D,1));
                training_mat=[training_mat;D(1:stop,:)];
                testing_mat=[testing_mat;D(stop+1:end,:)];
                training_labels=[training_labels;L(1:stop)];
                testing_labels=[testing_labels;L(stop+1:end,:)];        
        else
            
                D=Data_per_subject(start:start+time_in_blocks-1,:);
                L=labels(start:start+time_in_blocks-1,:);

                
                stop=round(prc_train*size(D,1));
                training_mat=[training_mat;D(1:stop,:)];
                testing_mat=[testing_mat;D(stop+1:end,:)];
                training_labels=[training_labels;L(1:stop)];
                testing_labels=[testing_labels;L(stop+1:end,:)];
end

end
end
if cleaning
    training_mat(:,end+1)=deal(1);
    testing_mat(:,end+1)=deal(2);
    z=[training_mat;testing_mat];
  [zelano_mat,a,c]=aharon_cleaning_HCTSA(mat);
% HCTSA_re_mat=HCTSA_re_mat(a,:);
zelano_labels=training_labels(a);
if size(zelano_mat,1)~=size(zelano_labels,1)
    zelano_labels=zelano_labels(c);
end
[zelano_test,a,c]=aharon_cleaning(testing_mat);
% HCTSA_re_test=HCTSA_re_test(a,:);
zelano_testing_labels=testing_labels(a);

if size(zelano_test,1)~=size(zelano_testing_labels,1)
    zelano_testing_labels=zelano_testing_labels(c);
end

else
        zelano_mat=training_mat;
zelano_labels=training_labels;
zelano_test= testing_mat;
zelano_testing_labels=testing_labels;
end

% params=load('/Users/worg/Documents/github_repo/corrected_vals_InfFS.mat');
% parameters=params.corrected_val;
% parameters=1:119;

  %  for perm=1:10
    [mdl] = mediumNeuralNetwork(zelano_mat(:,parameters),zelano_labels);
    labels_hat = mdl.predictFcn(zelano_test(:,parameters)); 
 C = confusionmat(zelano_testing_labels,labels_hat);
% acc(perm)=sum(diag(C))./sum(C(:));
%         ac=0;
% 
%         for row=1:length(C)
%             prc=C(row,:)/sum(C(row,:));
%             [prc_sorted,idx_sorted]=sort(prc,'descend');
%             %    if prc_sorted(1)-prc_sorted(2)>0.1
%             if idx_sorted(1)==row
%                 ac=ac+1;
%             end
% 
%         end
%         acc_id(perm)=ac./length(C)*100;
%     end
% fprintf(['acc_id=' num2str(mean(acc_id)) '\n'])
% 
if normalize
    if overlap
        save([directory '/result_HCTSA_same_day/acc_id_HCTSA_' WSA '_' num2str(block_length) 'min_blocks_' num2str(prc_train) '_' num2str(timings(iii)) 'min_gender_' num2str(s) 'parameters_' num2str(size(AllSubjData,2)) '.mat'],'C',"labels_hat", 'zelano_testing_labels','parameters');
    else
        save([directory '/result_HCTSA_same_day/acc_id_HCTSA_' WSA '_' num2str(block_length) 'min_blocks_'  num2str(prc_train) '_' num2str(timings(iii)) 'min_no_overlap_gender' num2str(s) 'parameters_' num2str(size(AllSubjData,2)) '.mat'],'C',"labels_hat", 'zelano_testing_labels','parameters');
    end
else
    if overlap
        save([directory '/result_HCTSA_same_day/acc_id_HCTSA_' WSA '_' num2str(block_length) 'min_blocks_' num2str(prc_train) '_' num2str(timings(iii)) 'min_gender' num2str(s) 'parameters_' num2str(size(AllSubjData,2)) '.mat'],'C',"labels_hat", 'zelano_testing_labels','parameters');
    else
        save([directory '/result_HCTSA_same_day/acc_id_HCTSA_'  WSA '_' num2str(block_length) 'min_blocks_' num2str(prc_train) '_' num2str(timings(iii)) 'min_no_overlap_' num2str(s) 'first_parameters_' num2str(size(AllSubjData,2)) '.mat'],'C',"labels_hat", 'zelano_testing_labels','parameters');
    end
end
end
end