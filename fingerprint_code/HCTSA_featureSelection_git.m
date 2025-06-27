
rng(3)
state=1;
trainig_mat=[];
training_labels=[];

directory_to_use='/Users/worg/Documents/fingerprint_code/';

if state==1
    WSA='wake';
    HCTSA_Wake=dir([ directory_to_use 'Accelerometer/HCTSA_*_magnitude.mat']);
    %HCTSA_Wake=dir('/Volumes/Mac/Restored MacBook Pro/identification_paper/HCTSA/mat_files_250/*/HCTSA*.mat');

for i = 1:length(HCTSA_Wake)
    load([HCTSA_Wake(i).folder '/' HCTSA_Wake(i).name]);

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


% if exist(['PermutationAccuracyResults_' fieldname '_' WSA '.mat'], 'file')
%     load(['PermutationAccuracyResults_' fieldname '_' WSA '.mat']);
% else


%% choose low and high subjects
%labels=cell2mat(labels);


classifiersType = 'Linear'; %Tree,SVM,Linear,RUSBoost,NeuralNetwork
    toPrintResults = false;
    num_of_permutations = 30;
    accuracyResults = cell(num_of_permutations, 1);
    rand_accuracyResults = cell(num_of_permutations, 1);

%     if exist(['PermutationAccuracyResults_' classifiersType '_' fieldname '_' WSA '_' num2str(num_of_permutations) 'permutations.mat'], 'file')
% load(['PermutationAccuracyResults_' classifiersType '_' fieldname '_' WSA '_' num2str(num_of_permutations) 'permutations.mat'])
%     else
trainig_mat(:,std(trainig_mat)==0)=[];
[trainig_mat, colsToKeep]=clean_sparse(trainig_mat,0.7);




labels=unique(training_labels);
val_to_train=zeros(size(trainig_mat,1),1);
    p_train=0.5;
n=round(sqrt((p_train)*size(training_labels,1)));
n2=round(sqrt((1-p_train)*size(training_labels,1)));

    for idxx=1:num_of_permutations
    v_to_train=randperm(size(labels,1),round(p_train*size(labels,1)));
    v_to_test=setdiff(1:size(labels,1), v_to_train);
    for ii=1:length(v_to_train)
        tmp=labels(v_to_train(ii));
        a=strcmpi(tmp{:},training_labels);
        val_to_train=val_to_train+a;
    end

    val_to_test=-(val_to_train-1);

    vars_for_opt=trainig_mat(logical(val_to_train),:);
    parameters_to_use=find_best_params_binary_HCTSA(vars_for_opt,training_labels(logical(val_to_train)),n);
    new_table=trainig_mat(logical(val_to_test),parameters_to_use(1:n));
    labels_new=training_labels(logical(val_to_test));
table1 = addvars(array2table(new_table),labels_new,'NewVariableNames','Group');
    x(idxx).v_to_train=v_to_train;
    x(idxx).parameters_chosen=parameters_to_use;

    end  

       fprintf('Finished all iterations (%d) in %1.3f seconds.\n', num_of_permutations, toc(start_time));
    save(['PermutationAccuracyResults_HCTSA_' WSA '_' num2str(num_of_permutations) 'permutations_' num2str(n) '.mat'], 'x');


%acc_id(idxx)=run_HCTSA_per_sbj_from_mat(table1,0.85,100,1);
    
    
 %   end

    %end

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