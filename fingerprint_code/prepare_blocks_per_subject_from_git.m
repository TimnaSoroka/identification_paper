function prepare_blocks_per_subject_from_git(directory_to_use,AllSubjData,WSA,normalize,SeparateNost,block_length_in_minutes,sliding_window_in_minutes,train_by_hours,prc_train,UseSelfReportedTimings)


%%
% if ~UseSelfReportedTimings
%     %'/Users/timnas/Documents/projects/24h_recordings/accelero'
%     load([directory_to_use '/accdata.mat']);
% end

%load('dictionary.mat')
% xtrain=[];
% training_labels=[];

for i=1:size(AllSubjData,1)
    subjData=AllSubjData(i);
    subjectName=subjData.folder(end-7:end);
    Data=load([subjData.folder '/' subjData.name]);
    %
    % % code_old=dictionary.old(slashes(end))
    % % code_new=
    %
    % [qa.startpoint,qa.length_sessions,qa.corrupted,qa.CorruptedAccelero,DataToUse] =technical_qa(subjData);
    % %% get timings
    %
    % sbj=find(strcmpi(string(subjData.Name),[accdata.subjectName]));
    %
    % timings_per_subj=Sleep_Wake_timings(subjData,sbj,accdata,UseSelfReportedTimings);
    %
    % %% create data wake, data_sleep and data all
    % %  takeOnlyContinuesMeasures=true; / mornings...
    % CutEdge=1; %exclude morning shorter than CutEdge (in Hours)
    % ExcludeNap=true; %exclude nap
    % [Data_wake,Data_sleep]=extract_wake_sleep_raw(DataToUse,timings_per_subj,CutEdge,ExcludeNap);
    % Data_all=DataToUse;
    if strcmpi(WSA,'wake')
        Data_wake=Data;
    elseif strcmpi(WSA,'sleep')
        Data_sleep=Data;
    end


    % Raw(i).Data_wake=  Data_wake(:,[6, 7, 8]);
    % Raw(i).Data_sleep=  Data_sleep(:,[6, 7, 8]);
    % Raw(i).Data_all=Data_all(:,[6, 7, 8]);
    % Raw(i).Name=subjectName;

    % end

    % if train_by_hours
    %         How_long_to_train=2*60;
    %         How_long_to_test=2*60;
    %         StartPoint_in_minutes=1;
    %         StartPoint=StartPoint_in_minutes*60*6;
    %         How_long_train=How_long_to_train*60*6;
    %         How_long_test=How_long_to_test*60*6;
    %     end
    %     block_length=block_length_in_minutes*60*6;
    %
    %
    if strcmpi('wake',WSA)
        [raw_in_block_sum]= data_into_blocks(block_length_in_minutes,sliding_window_in_minutes,Data_wake,SeparateNost,normalize);
        %  %         [raw_in_block_sum]= accelerometerdata_into_blocks(block_length_in_minutes,sliding_window_in_minutes,Data_wake,SeparateNost,normalize);
        %
    elseif strcmpi('sleep',WSA)
        [raw_in_block_sum]= data_into_blocks(block_length_in_minutes,sliding_window_in_minutes,Data_sleep,SeparateNost,normalize);
    end
    %raw_in_block_sum(end,:)=[];
    %
    %
    labels=repmat({subjectName},size(raw_in_block_sum));
    %
    %     if train_by_hours
    %         training=raw_in_block_sum_sum(1:How_long_train/block_length,:);
    %
    %         testing=raw_in_block_sum(end-How_long_test/block_length+1:end,:);
    %
    %         labels_training=labels(1:length(training),:);
    %         labels_testing=labels(1:length(testing),:);
    %     else
    %         training=raw_in_block_sum(1:floor(prc_train*length(raw_in_block_sum)),:);
    %
    %         testing=raw_in_block_sum(floor(prc_train*length(raw_in_block_sum))+1:end,:);
    %
    %         labels_training=labels(1:floor(prc_train*length(raw_in_block_sum)),:);
    %         labels_testing=labels(floor(prc_train*length(raw_in_block_sum))+1:end,:);
    %     end
if SeparateNost
        %         % if ~exist([directory_to_use '/Accelerometer/Data/SeparateNost_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' subjectName],'dir')
        %         %     mkdir([directory_to_use '/Accelerometer/Data/SeparateNost_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' subjectName])
        %         % end
        if ~exist([directory_to_use '/Data/SeparateNost_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' subjectName],'dir')
            mkdir([directory_to_use '/Data/SeparateNost_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' subjectName])
        end
        %
        if strcmpi('wake',WSA)
            if normalize
                %   save([directory_to_use '/Accelerometer/Data/SeparateNost_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' subjectName '/' subjectName '_raw_full_wake_normalized_' num2str(prc_train) 'prc_train.mat'],"training","labels_training");
            else
                %            save([directory_to_use '/Accelerometer/Data/SeparateNost_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' subjectName '/' subjectName '_raw_full_wake_' num2str(prc_train) 'prc_train.mat'],"training","labels_training");
                save([directory_to_use '/Data/SeparateNost_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' subjectName '/' subjectName '_raw_full_wake_' num2str(prc_train) 'prc_train.mat'],"training","labels_training");
                %
            end

         elseif  strcmpi('sleep',WSA)
                if normalize
                    %    save([directory_to_use '/Data/SeparateNost_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' subjectName '/' subjectName '_raw_full_sleep_normalized_' num2str(prc_train) 'prc_train.mat'],"training","labels_training");
                else
                    save([directory_to_use '/Data/SeparateNost_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' subjectName '/' subjectName '_raw_full_sleep_' num2str(prc_train) 'prc_train.mat'],"training","labels_training");
                end
            end
else
            if ~exist([directory_to_use '/Data/sum_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' subjectName],'dir')
                mkdir([directory_to_use '/Data/sum_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' subjectName])
            end
            if strcmpi('wake',WSA)
                if normalize
  %                  save([directory_to_use '/Data/sum_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' subjectName '/' subjectName '_raw_full_wake_normalized_' num2str(prc_train) 'prc_train.mat'],"training","labels_training");
                else
                    save([directory_to_use '/Data/sum_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' subjectName '/' subjectName '_raw_full_wake.mat'],"raw_in_block_sum","labels");
                end

            elseif  strcmpi('sleep',WSA)
                if normalize
                    save([directory_to_use '/Data/sum_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' subjectName '/' subjectName '_raw_full_sleep_normalized_' num2str(prc_train) 'prc_train.mat'],"training","labels_training");
                else
                    save([directory_to_use '/Data/sum_' num2str(block_length_in_minutes) 'min_blocks_per_subj/' subjectName '/' subjectName '_raw_full_sleep_' num2str(prc_train) 'prc_train.mat'],"training","labels_training");
                end
            end
end

end