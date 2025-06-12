function create_BM_per_sbj(directory,AllSubjData,SeparateNost,WSA,zscored,block_length_in_minutes)
% % %directory='/Users/timnas/Documents/projects/identification paper/identification_same day/idwntification_same_day_zelano/code/';
% % 
% % directory='/Users/worg/Documents/identificationPapar/';
% % load([ directory '/AllSubjData.mat'])
% % 
% % 
% % % choose parameters:
% % SeparateNost=false;
% % WSA='wake';
% % %WSA='sleep';
% % zscored=true;
% % block_length_in_minutes=5;
% % 
% % % choose subjects:
% % subject_to_use=importdata([directory '/SubjectsToUse.xlsx']);
% % subject_to_use=subject_to_use.all_subj;
% % 
% % subjectsNamesToRemoveFromNasalCycleAnalysis=setdiff({AllSubjData.Name},subject_to_use);
% % % subjectsNamesToRemoveFromNasalCycleAnalysis = setdiff({allAnalysisFields(strcmp({allAnalysisFields.Group}, 'ADHD')).SubjectName}, 'AKS229_rit1');
% % subjectsIndicesToRemoveFromNasalCycleAnalysis = cellfun(@(str) any(strcmp(str, subjectsNamesToRemoveFromNasalCycleAnalysis)), {AllSubjData.Name});
% % AllSubjData = AllSubjData(~subjectsIndicesToRemoveFromNasalCycleAnalysis);

%%
for sbj=1:size(AllSubjData,1)
    % SubjectName=AllSubjData(sbj).Name;
                SubjectName=AllSubjData(sbj).folder(end-7:end);
    if zscored
        file=dir([directory '/Data/sum_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' SubjectName '/' SubjectName  '*' WSA '*normalized_1prc_train.mat']);
    else 
        file=dir([directory '/Data/sum_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' SubjectName '/' SubjectName '*raw*_' WSA '.mat']);
    end

    if isempty(file)
        pause(0.1)
    end
                load([file.folder '/' file.name])
% xtrain=reshape(xtrain,[size(xtrain,1)*size(xtrain,2) 1]);
% training_labels=reshape(training_labels,[size(xtrain,1)*size(xtrain,2) 1]);
% 
% xtest=reshape(xtest,[size(xtest,1)*size(xtest,2) 1]);
% testing_labels=reshape(testing_labels,[size(xtest,1)*size(xtest,2) 1]);

xtrain=raw_in_block_sum;
% 
%  xtest=xtest(:,1);
% testing_labels=testing_labels(:,1);


block_length=block_length_in_minutes;

for i=1:size(xtrain,1)
    for ii=1:size(xtrain,2)
    TimeSeries=xtrain{i,ii};
    %calibrated_vals=TimeSeries*0.001438 + 0.004754;

     peaks=peaks_from_ts2(TimeSeries,6);
%        peaks=peaks_from_ts_calibrated(calibrated_vals');
% % %     figure
% % %     plot(TimeSeries)
% % %     hold on
% % %     plot([peaks.PeakLocation],[peaks.PeakValue],'ko')
zelano_training(i,ii)=calculate_z(peaks,block_length);
TimeSeries=[];

end
end
% for i=1:length(xtest)
%     TimeSeries=xtest{i};
%     peaks=peaks_from_ts(TimeSeries');
% zelano_testing(i)=calculate_z(peaks,block_length);
% TimeSeries=[];
% end

mat=zelano_training;
% testing_mat=struct2table(zelano_testing);

% save('zelano_train_test_full42wake','training_mat','testing_mat','training_labels','testing_labels');
if zscored
    save([directory '/Data/sum_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' SubjectName '/' SubjectName '_BM_' WSA '_normalized.mat'],'mat','labels');
else
    save([directory '/Data/sum_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' SubjectName '/' SubjectName '_BM_' WSA '.mat'],'mat','labels');
end

% save('zelano_train_test_1h_train_1h_test_97wake','training_mat','testing_mat','training_labels','testing_labels');
clearvars training_mat training_labels zelano_training

end
end








