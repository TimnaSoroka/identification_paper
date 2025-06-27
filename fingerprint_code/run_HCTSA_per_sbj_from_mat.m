function acc_id=run_HCTSA_per_sbj_from_mat(table1,prc_train,timings,start,cleaning,rand)

%rng(1)
rng(1500)
block_length=5;

for iii=1:length(timings)
    training_mat=[];
    training_labels=[];
    testing_mat=[];
    testing_labels=[];

    time_to_check=timings(iii);
    time_in_blocks=round(time_to_check/block_length);

    list=unique(table1(:,end));
    for i=1:size(list,1)

        SubjectName=list.Group(i);
        a=strcmpi(SubjectName,table1.Group(:));
        Data_per_subj=table1(a,1:end-1);
        labels=table2cell(table1(a,end));
        Data_per_subject=table2array(Data_per_subj);
  %      if size(Data_per_subject,1)-start<start+time_in_blocks
            % all_values(sbj,:)=deal(nan);
%            fprintf('subject %s were wake only %f hours, hence excluded here \n', SubjectName,(size(Data_per_subject,1)*5)/60 )
        if time_to_check==100
            D=Data_per_subject;
            L=table2cell(labels);


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

if cleaning
    if strcmpi(class(training_mat),'double')
        training_mat_for_clean=training_mat;
        testing_mat_for_clean=testing_mat;
    else
               training_mat_for_clean=table2array(training_mat);
        testing_mat_for_clean=table2array(testing_mat);
    end
        training_mat_for_clean(:,end+1)=deal(1);
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
    if strcmpi(class(training_mat),'double')
        zelano_mat=training_mat;
                zelano_test=testing_mat;
    else
            zelano_mat=table2array(training_mat);
                zelano_test= table2array(testing_mat);
    end
        zelano_labels=training_labels;
        zelano_testing_labels=testing_labels;
    end

    if rand
        zelano_labels=zelano_labels(randperm(size(zelano_labels,1),size(zelano_labels,1)));
        zelano_testing_labels=zelano_testing_labels(randperm(size(zelano_testing_labels,1),size(zelano_testing_labels,1)));
    end
params=1:25;
numPerms=5;
acc_id=nan(numPerms,1);

for perm=1:numPerms
            [mdl, validationAccuracyReal(perm)] = mediumNeuralNetwork(zelano_mat(:,params),zelano_labels);
    labels_hat = mdl.predictFcn(zelano_test(:,params));
    C = confusionmat(zelano_testing_labels,labels_hat);
    %acc(perm)=sum(diag(C))./sum(C(:));
        ac=zeros(size(C,1),1);
    parfor row=1:length(C)
        prc=C(row,:)/sum(C(row,:));
        [~,idx_sorted]=sort(prc,'descend');
        %    if prc_sorted(1)-prc_sorted(2)>0.1
        if idx_sorted(1)==row
                ac(row)=1;
        end

    end
        acc_id(perm)=sum(ac)/length(ac)*100;
end
fprintf(['acc_id=' num2str(mean(acc_id)) '\n'])

end

end