function create_LI_per_sbj_git(directory,AllSubjData,SeparateNost,WSA,zscored,block_length_in_minutes,Fs,noiseThreshold)
% % %directory='/Users/timnas/Documents/projects/identification paper/identification_same day/idwntification_same_day_zelano/code/';
%addpath('/Users/worg/Documents/LI_per_breath')
counter=0;
Fs=6;
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
        subjData=AllSubjData(sbj);
        SubjectName=subjData.folder(end-7:end);
        
        if zscored
        file=dir([directory '/Data/SeparateNost_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' SubjectName '/' SubjectName  '*' WSA '*normalized_1prc_train.mat']);
    else 
        file=dir([directory '/Data/SeparateNost_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' SubjectName '/*raw*' WSA '.mat']);
    end

                load([file.folder '/' file.name])
% xtrain=reshape(xtrain,[size(xtrain,1)*size(xtrain,2) 1]);
% training_labels=reshape(training_labels,[size(xtrain,1)*size(xtrain,2) 1]);
% 
% xtest=reshape(xtest,[size(xtest,1)*size(xtest,2) 1]);
% testing_labels=reshape(testing_labels,[size(xtest,1)*size(xtest,2) 1]);

xtrain=raw_in_block_sum;
% 


% Initialize
removedIndices = [];
keepCells = true(1, numel(xtrain));  % Logical index to keep

for i = 1:numel(xtrain)
    currentMatrix = xtrain{i};
    numZeros = sum(abs(currentMatrix(:)) < abs(0.017));  % Count zeros across both rows
    differences1=diff(currentMatrix(:,1))==0 ;
    differences2=diff(currentMatrix(:,2))==0 ;
    if numZeros > 12*Fs*block_length_in_minutes || sum(differences1) > 12*Fs*block_length_in_minutes ||  sum(differences2) > 12*Fs*block_length_in_minutes
        keepCells(i) = false;
        removedIndices(end+1) = i; %#ok<SAGROW> % Store the removed index
    end
end

xtrain(removedIndices)=[];
labels(removedIndices)=[];
% Remove the unwanted cells
if isempty(xtrain)
        fprintf('no data for %s',SubjectName)
    continue;
end
%  xtest=xtest(:,1);
% testing_labels=testing_labels(:,1);


block_length=block_length_in_minutes;
%clearvars NC_parameters

for i=1:length(xtrain)
    TimeSeries=xtrain{i};
TimeSeries(:,2)=-TimeSeries(:,2);

%NC_parameters(i,ii)=NasalCycleParameters(TimeSeries,SubjectName,Fs,noiseThreshold);
NC_parameters_old(i)=NasalCycleParameters(TimeSeries,6,0);
breaths = TraceToBreaths(TimeSeries, 6); 
LI=[breaths.LI_by_peak];
NostrilCorrR=corrcoef([breaths.Peak_Right],[breaths.Peak_Left]);
if size(LI,2)>5*block_length_in_minutes
NC_parametersN(i).meanLI=mean(LI);
NC_parametersN(i).meanAmp=mean(abs(LI));
NC_parametersN(i).stdAmp=std(abs(LI));
NC_parametersN(i).stdLI=std(LI);
NC_parametersN(i).Nostril_Corr = NostrilCorrR(2,1);
else
NC_parametersN(i).meanLI=nan;
NC_parametersN(i).meanAmp=nan;
NC_parametersN(i).stdAmp=nan;
NC_parametersN(i).stdLI=nan;
NC_parametersN(i).Nostril_Corr =nan;
end

% % %     DataToLI=[training_L{i,1};training_R{i,1}];
% % % Fs=6;
% % % noiseThreshold=5;
% % %     if size(DataToLI,2)<1000
% % %         Resp=[];
% % %     else
% % %         [Resp,~]=hilbert24(DataToLI', Fs, noiseThreshold);
% % %     end
% % %     if size(Resp,2)<4
% % % measureResults(i).MeanLateralityIndex = nan;
% % % measureResults(i).stdLateralityIndex = nan;
% % % measureResults(i).stdAmplitudeLI = nan;
% % % measureResults(i).MeanAmplitudeLI = nan;
% % % measureResults(i).Nostril_Corr_RValue = nan;
% % % measureResults(i).Nostril_Corr_PValue = nan;
% % %     else
% % % % one number variables
% % % Laterality_Index=(Resp(1,:)-Resp(2,:))./(Resp(1,:)+Resp(2,:));
% % % measureResults(i).MeanLateralityIndex = mean(Laterality_Index);
% % % measureResults(i).stdLateralityIndex = std(Laterality_Index);
% % % measureResults(i).stdAmplitudeLI = std(abs(Laterality_Index));
% % % measureResults(i).MeanAmplitudeLI = mean(abs(Laterality_Index));
% % % [NostrilCorrR, NostrilCorrP] = corrcoef(Resp(1,:), Resp(2,:));
% % % measureResults(i).Nostril_Corr_RValue = NostrilCorrR(2,1);
% % % measureResults(i).Nostril_Corr_PValue = NostrilCorrP(2,1);
% % %     end
end

%mat=NC_parameters;

if zscored
    save([directory '/Data/SeparateNost_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' SubjectName '/' SubjectName '_LI_params_by_peak_' WSA '.mat'],'mat','labels');
else
    save([directory '/Data/SeparateNost_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' SubjectName '/' SubjectName '_LI_params_by_peak_' WSA '.mat'],'NC_parameters_old','NC_parametersN','labels');
end
clearvars TimeSeries NC_parametersN NC_parameters_old

% save('zelano_train_test_1h_train_1h_test_97wake','training_mat','testing_mat','training_labels','testing_labels');
%clearvars training mat training_labels zelano_training
counter=counter+1;
fprintf('finished %d\n',counter)
end
end








