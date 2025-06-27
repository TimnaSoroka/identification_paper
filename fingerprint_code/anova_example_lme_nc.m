clear
%close all
%addpath('/Users/worg/Documents/identificationPapar/newFigs')
rng('default')
directory_to_use='/Users/worg/Documents/fingerprint_code'; %/Users/timnas/Documents/projects/24h_recordings/NC_24Hours_Analysis/
% directory_to_use='/Users/worg/Documents/lior_data/Timna'; %/Users/timnas/Documents/projects/24h_recordings/NC_24Hours_Analysis/
% load([directory_to_use '/QA_updated4.mat'])
load([directory_to_use '/QA_updated.mat'])
%load('/Users/worg/Documents/identificationPapar/LI_mat_sleep.mat')

load([ directory_to_use '/vars.mat']);
zscored=0;
WSA='wake';
%WSA='sleep';
block_length=30;


if strcmpi(WSA,'wake')
    load([ directory_to_use '/LI_mat_' num2str(block_length) '_wake.mat'])
elseif strcmpi(WSA,'sleep')
load(['/Users/worg/Documents/identificationPapar/LI_mat_' num2str(block_length) '_sleep.mat'])
end

QA=AllSubjData(1:97);
print_results=0;

for f=8 %[4:8,13]%[3,13,6:8]
    ff=fieldnames(QA);
    fieldname=ff{f};

    labels={QA.(fieldname)};
    names={QA.Code};

    [V1_sorted, V2_sorted, common_labels] = sort_vectors_by_labels(LI_params, NameList, labels, names);
    [nameList_sorted] = sort_vectors_by_labels(NameList_long, NameList, labels, names);


    correlation_val=exstruct_from_struct(V1_sorted);
    labels=cell2mat(V2_sorted);

    if strcmpi(WSA,'sleep')
        g=strcmpi('w899_no_rit1',{NameList{:}});
        labels(g)=nan;
    end
        if strcmpi(WSA,'sleep')
        g=strcmpi('GG903_c1',{NameList{:}});
        labels(g)=nan;
    end
    %
    q1=labels<=prctile(labels,15);
    q3=labels>=prctile(labels,85);


    values1=V1_sorted;


    values1_Low=values1(q1);
    values1_High=values1(q3);

    names_long_low=nameList_sorted(q1);
    names_long_high=nameList_sorted(q3);

[subjectsL,TimeL,values1_L]=prepare_anova_NC(values1_Low,names_long_low);
[subjectsH,TimeH,values1_H]=prepare_anova_NC(values1_High,names_long_high);

    Subject=[subjectsL;subjectsH];
    Program=[ones(numel(subjectsL),1);2*ones(numel(subjectsH),1)]';
    Time=[TimeL,TimeH];
    yy=table2array([values1_L;values1_H]);



    xx=logical(sum(isnan(yy),2));
    Program(xx)=[];
    Subject(xx)=[];
    yy(xx,:)=[];
    Time(xx)=[];

    for ii=1:size(yy,2)
    tbl = table(Program',Subject,Time',yy(:,ii),'VariableNames',{'Group','Subject','Time','Y'});
    tbl.Subject = nominal(tbl.Subject);
    tbl.Group = nominal(tbl.Group);
    lme = fitlme(tbl,'Y ~  Group  + (1 | Subject) + (Time | Subject)+ (1 | Time)');%,...

    % stat=mes1way([tbl.Y],'partialeta2','group',Program');
    % TableToCSV(ii).effect_size=stat.partialeta2;
    [firstG,average_mm,SE_mm]=prepare_mm(values1_Low,ii)    ;
[secondG,average_mm1,SE_mm1]=prepare_mm(values1_High,ii)    ;

    a{ii}=anova(lme);

    groupData_L = table2array(values1_L(:,ii));
    TableToCSV(ii).mean_group_L = mean(groupData_L,'omitmissing');
    TableToCSV(ii).std_group_L = std(groupData_L,'omitmissing');
    groupData_H = table2array(values1_H(:,ii));
    TableToCSV(ii).mean_group_H = mean(groupData_H,'omitmissing');
    TableToCSV(ii).std_group_H = std(groupData_H,'omitmissing');

    TableToCSV(ii).FStat=a{ii}.FStat(2);
    TableToCSV(ii).DF1=a{ii}.DF1(2);
    TableToCSV(ii).DF2=a{ii}.DF2(2);
    TableToCSV(ii).p_val=a{ii}.pValue(2);

    F_val = TableToCSV(ii).FStat;  % Row 2 is 'Group' (row 1 = intercept)
df_effect = TableToCSV(ii).DF1;
df_error = TableToCSV(ii).DF2;

% Compute partial eta squared
eta_squared_partial = (F_val * df_effect) / (F_val * df_effect + df_error);
%TableToCSV(ii).effect_size=eta_squared_partial;
CI = coefCI(lme);
%TableToCSV(ii).CI=CI;
%[TableToCSV(ii).Corr,TableToCSV(ii).CorrP]=corr(table2array(correlation_val(:,ii)),labels,"rows","complete","type","Spearman");

var_names=fieldnames(values1_High{1, 1}  );
    if a{ii}.pValue(2)<0.05
        f=figure('Color',[1 1 1],'Position',[460 429 885 326]);
         plot_across_time(firstG',secondG',var_names(ii),block_length)
        % ff=figure('Color',[1 1 1],'Position',[460 429 885 326]);
        % plot_all(firstG,secondG)
        if strcmpi('wake', WSA)
            savefig(f,['/Users/worg/Documents/identificationPapar/newFigs/fig/clean_' fieldname '_' num2str(block_length) '_wake_' var_names{ii} '_15prc'],'compact')
        else
            savefig(f,['/Users/worg/Documents/identificationPapar/newFigs/fig/clean_' fieldname '_' num2str(block_length) '_sleep_' var_names{ii} '_15prc'],'compact')
        end
        close all
        % if ii==8 && i==6
        % plot_across_time(firstG,secondG,ii)
        % elseif ii==6 && i==7
        %     plot_across_time(firstG,secondG,ii)
        % elseif ii==24 && i==8
        %fprintf('feature %d \n' ,ii);
        %title([fieldname ' ' num2str(a.pValue(2)) ' ' var_names(ii)])
    end

%sum(p_val<0.0021)
if strcmpi('wake',WSA)
    save([fieldname '_wake_table_supp_prc_1585_final.mat'],'TableToCSV');
else
    save([fieldname '_sleep_table_supp_prc_1585_final.mat'],'TableToCSV');
end
%[sorted,idx]=sort(p_val) ;
    end
p_c=[TableToCSV.p_val];
[adjusted_p_values,sig_vars]=benjamini_hochberg_correction(p_c([1:2,4,5]));
[adjusted_p_values,sig_vars]=benjamini_hochberg_correction(p_c([6:8,10]));
end


function plot_across_time(firstG,secondGroup,d,block_length)

timings=min([size(firstG,1),size(secondGroup,1)]);

firstG=firstG(1:timings,:);
secondGroup=secondGroup(1:timings,:);

for i=1:size(firstG,1)
    [~,test_p(i)]=ttest2(firstG(i,:),secondGroup(i,:));
end

A=mean(firstG,2,'omitnan');
B=mean(secondGroup,2,'omitnan');
% smoothing_factor=0.04;
% A = smooth(A, smoothing_factor, 'loess'); % 0.1 is the smoothing factor
% B = smooth(B, smoothing_factor, 'loess'); % 0.1 is the smoothing factor

SEM_A=std(firstG,0,2,'omitmissing')/sqrt(size(firstG,2));
SEM_B=std(secondGroup,0,2,'omitmissing')/sqrt(size(secondGroup,2));

% SEM_A = smooth(SEM_A, smoothing_factor, 'loess'); % 0.1 is the smoothing factor
% SEM_B = smooth(SEM_B, smoothing_factor, 'loess'); % 0.1 is the smoothing factor

% if d>24
%  param = [vars{d-24} ' Sleep'];
%  unit=add_unit24(d-24);
% else
param = d{:};
%unit=add_unit25(d);
% end
time = [5:block_length:timings*block_length];
% plot(smoothdata(mean([firstG{:}],'omitnan')),'bo')
% hold on
% plot(smoothdata(mean([secondGroup{:}],'omitnan')),'ro')

%   cb = cbrewer('qual', 'Set1', 5, 'pchip');
[cb] = cbrewer('qual', 'Set3', 12, 'pchip'); % set colors
%yyaxis left;
fill([time, fliplr(time)], [A' + SEM_A', fliplr(A' - SEM_A')], ...
    cb(4,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', 'Standard Error');
hold on
plot(time,A,'Color',cb(4,:),'LineWidth',2,'LineStyle','-')
%eb = errorbar(time,means_along_time_PD.(param),SEM_along_time_PD.(param),'LineStyle','none', 'Color', [cb(4,:) 0.8],'linewidth', 1);
fill([time, fliplr(time)], [B' + SEM_B', fliplr(B' - SEM_B')], ...
    cb(5,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', 'Standard Error');
plot(time,B,'Color',cb(5,:),'LineWidth',2,'LineStyle','-')
%eb1 = errorbar(time,means_along_time_control.(param),SEM_along_time_control.(param),'LineStyle','none', 'Color', [cb(5,:) 0.8],'linewidth', 1);
%ylim([0 inf])
xticks([1:60:time(end)]);
xticklabels([0:60:time(end)]);
xlabel('Time (minutes)');
param = regexprep(param,'_',' ');
ylabel([param ' ']);
ax = gca;
ax.FontSize = 15;
% test_p(test_p>0.05)=nan;
%     yyaxis right;
% plot(time, test_p, 'k', 'LineWidth', 1,'LineStyle','-.');
% ylabel('P value');
end

% figure;
% interactionplot([tbl.Time], double([tbl.Program]));
% title('Interaction Plot');
% xlabel('Time Points');
% ylabel('Mean Values');
% p_val(:,7)=[];
%
% p_val<0.001

function [y,subjects,TimePoints,mm]=calculate_mean_per_group(values1_L,ii)
num_tables = size(values1_L,2);
load('vars.mat')
for i = 1:length(var_names)
    containsPause(i) = contains(var_names{i}, 'Pause');
end
pause_vars=find(containsPause);

subjects=[];
TimePoints=[];
y=[];
for i = 1:length(values1_L)
    sizes(i) = size(values1_L{i},1); % Store size of each table
end

if ismember(ii,[1 2 5 6 9 10])
    load('/Users/worg/Documents/calibration_ADinst_Holter/calibrations_fitresults.mat')
end

lengths = min(sizes);
for j=1:num_tables
    mean_val_1L=table2array(values1_L{j}(:,ii));
    if ismember(ii,pause_vars)
        mean_val_1L(isnan(mean_val_1L))=0;
    else
        mean_val_1L(isnan(mean_val_1L))=[];
    end
    if ismember(ii,[1 2 5 6 9 10])
        mean_val_1L=fitresult.p1*mean_val_1L + fitresult.p2;
    end
    subject_ID=j*ones(numel(mean_val_1L),1);
    Time=1:numel(mean_val_1L);
    subjects=[subjects;subject_ID];
    TimePoints=[TimePoints,Time];
    y=[y;mean_val_1L];
    mm{j}=mean_val_1L;
    clearvars Time mean_val_1L subject_ID
end


%X=mean(mean_val_1L,2,'omitmissing');
end

function [allVectors,averageVector,stdVector]=prepare_mm(C,ii)
ff=fieldnames(C{1});
for i = 1:length(C)
    sizes(i) = size(C{i},2); % Store size of each table
end
maxLength = round(mean(sizes));

for i = 1:length(C)
    currentLength = length(C{i});
currentVec=[C{i}.(ff{ii})];
    if currentLength <= maxLength
        % Pad with NaNs (or zeros, depending on your preference)
               % C{i} = [C{i}; nan(maxLength - currentLength,1)];
         CC{i} = [currentVec, nan(1,maxLength - currentLength)];
   %     CC{i} = [C{i}; zeros(maxLength - currentLength,1)];
    elseif currentLength > maxLength
        % Truncate the vector
        CC{i} = currentVec(1:maxLength);
    end
end
allVectors = vertcat(CC{:});
allVectors=remove_outliers(allVectors);
% Compute the average vector, ignoring NaNs
averageVector = mean(allVectors, 'omitnan');
stdVector = std(allVectors,0,1, 'omitnan');

end

function [adjusted_p_values,q]=benjamini_hochberg_correction(p_val)
p=p_val;
p=reshape(p,1,[]);
[v,idx]=sort(p);
disp(v(1));
adjusted_p_values=v*length(p);
m=length(v);
% Benjamini-Hochberg critical values (q-values)
q_values = (1:m) * 0.05 / m;
for i = 1:m
    adjusted_p_values(i) = min(v(i) * m / i, 1);
end

q=adjusted_p_values<0.05;
disp(sum(q))
%    disp(['In ' fieldname ' ' num2str(sum(q)) 'parameters chosen:'])
end

function dataMatrix=remove_outliers(dataMatrix)

meanVals = mean(dataMatrix, 1); % Compute mean for each column
stdVals = std(dataMatrix, 0, 1); % Compute standard deviation for each column

% Define outlier threshold (±2.5 standard deviations)
lowerBound = meanVals - 2.5 * stdVals;
upperBound = meanVals + 2.5 * stdVals;

% Find outliers (element-wise comparison for each column)
outlierIdx = (dataMatrix < lowerBound) | (dataMatrix > upperBound);

% Remove outliers by setting them to NaN
dataMatrix(outlierIdx) = NaN;
end

function [NC_wake,NC_sleep]=val_to_use(trainingmat)
a=[trainingmat.Mean_amplitude_LI_sleep]';
b=[trainingmat.Mean_amplitude_LI_wake]';
c=[trainingmat.MeanAmplitudeLI]';
d=[trainingmat.Mean_LI_sleep]';
e=[trainingmat.Mean_LI_wake]';
f=[trainingmat.MeanLateralityIndex]';
g=[trainingmat.Nostril_corr_Sleep]';
h=[trainingmat.Nostril_corr_Wake]';
i=[trainingmat.Nostril_Corr_RValue]';
j=[trainingmat.Average_Interval_length_during_sleep]';
k=[trainingmat.Average_Interval_length_during_wake]';
l=[trainingmat.Average_Interval_length]';

NC_wake=[b,e,h,k];
NC_sleep=[a,d,g,j];
end

function means_table=exstruct_from_struct(data_cells)

n_cells = numel(data_cells);
field_names = fieldnames(data_cells{1}); % Get field names from first struct
n_fields = numel(field_names);

% Loop over each cell
for i = 1:n_cells
    this_struct = data_cells{i};
    if isempty(this_struct)
        this_struct = cell2struct(num2cell(NaN(1,numel(field_names))), field_names, 2);
    end
        means_table(i,:)=mean(struct2table([this_struct(:)]),'omitmissing');
end
end