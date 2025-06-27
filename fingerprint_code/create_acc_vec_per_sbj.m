function create_acc_vec_per_sbj(directory,AllSubjData,SeparateNost,WSA,zscored,block_length_in_minutes)
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
                SubjectName=AllSubjData(sbj).folder(end-7:end);
    if zscored
        file=dir([directory '/Data/sum_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' SubjectName '/' SubjectName  '*' WSA '*normalized_1prc_train.mat']);
    else 
        file=dir([directory '/Data/Accelerometer/' SubjectName '/*.mat']);
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

for i=1:size(xtrain,2)
    TimeSeries=xtrain{i};
    %calibrated_vals=TimeSeries*0.001438 + 0.004754;
TimeSeries=TimeSeries/1024;
TimeSeries=TimeSeries';
acc_magnitude(i,:)= sqrt(TimeSeries(1,:).^2+TimeSeries(2,:).^2+TimeSeries(3,:).^2);
%        peaks=peaks_from_ts_calibrated(calibrated_vals');
% % %     figure
% % %     plot(TimeSeries)
% % %     hold on
% % %     plot([peaks.PeakLocation],[peaks.PeakValue],'ko')
TimeSeries=[];

end
% for i=1:length(xtest)
%     TimeSeries=xtest{i};
%     peaks=peaks_from_ts(TimeSeries');
% zelano_testing(i)=calculate_z(peaks,block_length);
% TimeSeries=[];
% end

% testing_mat=struct2table(zelano_testing);

% save('zelano_train_test_full42wake','training_mat','testing_mat','training_labels','testing_labels');
saveDir = [directory '/fingerprint_code/Accelerometer'];

% Check if the directory exists; if not, create it
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

% Now save your file in that directory
save([saveDir, '/magnitude_' SubjectName '_wake.mat'], 'acc_magnitude');

% save('zelano_train_test_1h_train_1h_test_97wake','training_mat','testing_mat','training_labels','testing_labels');
clearvars acc_magnitude
end
end









