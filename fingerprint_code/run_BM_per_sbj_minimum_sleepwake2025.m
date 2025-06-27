function acc_id=run_BM_per_sbj_minimum_sleepwake2025(AllSubjData,directory,WSA,normalize,overlap,cleaning,block_length,train_by_hours,prc_train,timings,start,rand)

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

if ~rand
    rng(500) 
end

for iii=1:length(timings)
    training_mat=[];
    training_labels=[];
    testing_mat=[];
    testing_labels=[];


    time_to_check=timings(iii);
    time_in_blocks=round(time_to_check/block_length);

    load('/Users/worg/Documents/identificationPapar/code/breathMetric_parameters/values1shorts.mat')

    for i=1:size(AllSubjData,2)
        subjData=AllSubjData(i);
        SubjectName=subjData.Name;
Data=values1_shorts{i};

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

        %for ii=1:length(o)
            Data_per_subject=table2array(Data);
labels=repmat({SubjectName},size(Data_per_subject,1),1);
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

        %end
    end
    if cleaning
        training_mat_for_clean=training_mat;
        training_mat_for_clean(:,end+1)=deal(1);
        testing_mat_for_clean=testing_mat;
        testing_mat_for_clean(:,end+1)=deal(2);
        labels_clean=[training_labels;testing_labels];
        labels_loc=[ones(length(training_labels),1);2*ones(length(testing_labels),1)];
        merged_mat=[training_mat_for_clean;testing_mat_for_clean];
        [zelano_mat,a,c]=aharon_cleaning(merged_mat);
        % HCTSA_re_mat=HCTSA_re_mat(a,:);
        zelano_labels=labels_clean(a);
        labels_n_loc=labels_loc(a);
        if size(zelano_mat,1)~=size(zelano_labels,1)
            zelano_labels=zelano_labels(c);
            labels_n_loc=labels_n_loc(c);
        end
        zelano_test=zelano_mat(zelano_mat(:,end)==2,:);
        zelano_train=zelano_mat(zelano_mat(:,end)==1,:);
        zelano_testing_labels=zelano_labels(labels_n_loc==2);
        train_labels=zelano_labels(labels_n_loc==1);

        zelano_train(:,end)=[];
        zelano_test(:,end)=[];
        clearvars zelano_mat zelano_labels

        zelano_mat=zelano_train;
        zelano_labels=train_labels;
    else
        zelano_mat=training_mat;
        zelano_labels=training_labels;
        zelano_test= testing_mat;
        zelano_testing_labels=testing_labels;
    end

    if rand
        zelano_labels=zelano_labels(randperm(size(zelano_labels,1),size(zelano_labels,1)));
        zelano_testing_labels=zelano_testing_labels(randperm(size(zelano_testing_labels,1),size(zelano_testing_labels,1)));
    end

    params=[1:16,18:25];

    for perm=1
        [mdl, validationAccuracyReal(perm)] = mediumNeuralNetwork(zelano_mat(:,params),zelano_labels);
        labels_hat = mdl.predictFcn(zelano_test(:,params));
        C = confusionmat(zelano_testing_labels,labels_hat);
        %confusionchart(zelano_testing_labels,labels_hat);
       %  acc(perm)=sum(diag(C))./sum(C(:));
       % ac=zeros(size(C,1),1);
       % 
       %  for row=1:length(C)
       %      prc=C(row,:)/sum(C(row,:));
       %      [prc_sorted,idx_sorted]=sort(prc,'descend');
       %      %    if prc_sorted(1)-prc_sorted(2)>0.1
       %      if idx_sorted(1)==row
       %          ac(row)=1;
       %      end
       % 
       %  end
        % acc_id(perm)=sum(ac)/length(ac)*100;
    end
    % fprintf(['acc_id=' num2str(mean(acc_id)) '\n'])

    if rand
        if overlap
            save([directory '/newFigs/result_BM_same_day/acc_id_zelano_' WSA '_' num2str(block_length) 'min_blocks_' num2str(prc_train) '_' num2str(timings(iii)) 'min_rand_' num2str(size(AllSubjData,2)) '_' num2str(datetime) '.mat'],'validationAccuracyReal',"labels_hat", 'zelano_testing_labels','C');
        else
            save([directory '/newFigs/result_BM_same_day/acc_id_zelano_' WSA '_' num2str(block_length) 'min_blocks_'  num2str(prc_train) '_' num2str(timings(iii)) 'min_no_overlap_rand_' num2str(size(AllSubjData,2)) '_' datestr(datetime) '.mat'],'validationAccuracyReal',"labels_hat", 'zelano_testing_labels','C');
        end
    else
        if overlap
            save([directory '/newFigs/result_BM_same_day/acc_id_zelano_' WSA '_' num2str(block_length) 'min_blocks_' num2str(prc_train) '_' num2str(timings(iii)) 'min_' num2str(size(AllSubjData,2)) '.mat'],'validationAccuracyReal',"labels_hat", 'zelano_testing_labels','C');
        else
            save([directory '/newFigs/result_BM_same_day/acc_id_zelano_'  WSA '_' num2str(block_length) 'min_blocks_' num2str(prc_train) '_' num2str(timings(iii)) 'min_no_overlap_' num2str(size(AllSubjData,2)) 'wake_capped.mat'],'validationAccuracyReal',"labels_hat", 'zelano_testing_labels','C');
        end
    end
end
end