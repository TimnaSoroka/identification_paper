

load('PermutationAccuracyResults_HCTSA_wake_7permutations_94.mat');
rng(1)
meanstate=1;
load('QA_updated4.mat');
QA=AllSubjData(1:97);
trainig_mat=[];
training_labels=[];
state=1;

if state==1
    WSA='wake';
    HCTSA_Wake={QA.Data_wake_HCTSA};
for i = 1:length(HCTSA_Wake)
        trainig_mat = [trainig_mat; HCTSA_Wake{i}];
        label=repmat({QA(i).Code},size(HCTSA_Wake{i},1),1);
        training_labels=[training_labels;label];
end
else
    WSA='sleep';
    HCTSA_Sleep={QA.Data_sleep_HCTSA};
for i = 1:length(HCTSA_Sleep)
        trainig_mat = [trainig_mat; HCTSA_Sleep{i}];
        label=repmat({QA(i).Code},size(HCTSA_Sleep{i},1),1);
        training_labels=[training_labels;label];
end
end

trainig_mat(:,std(trainig_mat)==0)=[];
[trainig_mat, colsToKeep]=clean_sparse(trainig_mat,0.7);

labels=unique(training_labels);
val_to_train=zeros(size(trainig_mat,1),1);
    p_train=0.5;
 n=round(sqrt((p_train)*size(training_labels,1)));
 n2=round(sqrt((1-p_train)*size(training_labels,1)));

for idxx=1:size(x,2)
    v_to_train=x(idxx).v_to_train;
    v_to_test=setdiff(1:size(labels,1), v_to_train);
    for ii=1:length(v_to_train)
        tmp=labels(v_to_train(ii));
        a=strcmpi(tmp{:},training_labels);
        val_to_train=val_to_train+a;
    end
        val_to_test=-(val_to_train-1);

    vars_for_opt=trainig_mat(logical(val_to_train),:);
    parameters_to_use=x(idxx).parameters_chosen;
    new_table=trainig_mat(logical(val_to_test),parameters_to_use(1:n));
    labels_new=training_labels(logical(val_to_test));
table1 = addvars(array2table(new_table),labels_new,'NewVariableNames','Group');

x(idxx).acc_id2=run_HCTSA_per_sbj_from_mat(table1,0.85,100,1);
end

%save('HCTSA_FS_Sleep_50.mat',"x");
%save('HCTSA_FS_params_7permu.mat',"x");
%save('HCTSA_sleep_15.mat',"x");

    function [cleanedData, colsToKeep]=clean_sparse(data,threshold)

% Initialize a logical array to identify columns to keep
colsToKeep = true(1, size(data, 2));

% Loop through each column
for col = 1:size(data, 2)
    % Calculate the percentage of the most frequent value
    [value, count] = mode(data(:, col)); % Get the most frequent value and its count
    percentage = count / size(data, 1); % Calculate percentage

    % Check if the percentage exceeds the threshold
    if percentage > threshold
        colsToKeep(col) = false; % Mark this column for removal
    end
end

% Remove the columns that exceed the threshold
cleanedData = data(:, colsToKeep);

end