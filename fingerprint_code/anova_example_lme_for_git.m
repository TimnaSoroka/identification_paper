            clear
%close all
rng('default')
directory_to_use='/Users/worg/Documents/fingerprint_code'; %/Users/timnas/Documents/projects/24h_recordings/NC_24Hours_Analysis/
% directory_to_use='/Users/worg/Documents/lior_data/Timna'; %/Users/timnas/Documents/projects/24h_recordings/NC_24Hours_Analysis/
% load([directory_to_use '/QA_updated4.mat'])
%load([directory_to_use '/demographic/QA_updated.mat'])
load([directory_to_use '/QA_updated.mat'])

%load([ directory_to_use '/vars.mat']);
zscored=0;
WSA='wake';

QA=AllSubjData(1:97);
print_results=0;

for i=13 %[3,13,6:8]
    ff=fieldnames(QA);
fieldname=ff{i};

        labels={QA.(fieldname)};
          labels=cell2mat(labels);
         % labels(isnan(labels))=[];
          [labels_sorted,idx_sorted]=sort(labels);
          % q1=idx_sorted(1:10);
          % q3=idx_sorted(end-9:end);
          % 
q1=labels<=prctile(labels,15);
 q3=labels>=prctile(labels,85);
            values1={QA.Data_wake};
            values2={QA.Data_sleep};
           
            values1_L=values1(q1);
            values1_H=values1(q3);
            
            values2_L=values2(q1);
            values2_H=values2(q3);

            [X,labels]=readDATA50p(QA,fieldname);
for ii=1:25
    %[1,5,9,8] 
    if strcmpi('wake',WSA)
    [TableToCSV(ii).Corr,TableToCSV(ii).CorrP]=corr(X(:,ii),labels',"rows","complete","type","Spearman");
    [y,subjects,TimePoints,mm]=calculate_mean_per_group(values1_L,ii);
            [y1,subjects1,TimePoints1,mm1]=calculate_mean_per_group(values1_H,ii);
    else
            [TableToCSV(ii).Corr,TableToCSV(ii).CorrP]=corr(X(:,ii+25),labels',"rows","complete","type","Spearman");
    [y,subjects,TimePoints,mm]=calculate_mean_per_group(values2_L,ii);
            [y1,subjects1,TimePoints1,mm1]=calculate_mean_per_group(values2_H,ii);

    end

[firstG,average_mm,SE_mm]=prepare_mm(mm)    ;
[secondG,average_mm1,SE_mm1]=prepare_mm(mm1)    ;

Subject=[subjects;subjects1+subjects(end)]';
Program=[ones(numel(y),1);2*ones(numel(y1),1)]';
Time=[TimePoints,TimePoints1];
yy=[y;y1]';

xx=isnan(yy);
Program(xx)=[];
Subject(xx)=[];
yy(xx)=[];
Time(xx)=[];

tbl = table(Program',Subject',Time',yy','VariableNames',{'Group','Subject','Time','Y'});
tbl.Subject = nominal(tbl.Subject);
tbl.Group = nominal(tbl.Group);
lme = fitlme(tbl,'Y ~  Group  + (1 | Subject) + (Time | Subject)+ (1 | Time)');%,...

%stat=mes1way([tbl.Y],'partialeta2','group',Program');
%TableToCSV(ii).effect_size=stat.partialeta2;

a{ii}=anova(lme);

    groupData_L = y;
    TableToCSV(ii).mean_group_L = mean(groupData_L,'omitmissing');
    TableToCSV(ii).std_group_L = std(groupData_L,'omitmissing');
TableToCSV(ii).raw_L=y;
    TableToCSV(ii).raw_H = y1;
 TableToCSV(ii).mean_group_H = mean(groupData_H,'omitmissing');
    TableToCSV(ii).std_group_H = std(groupData_H,'omitmissing');
%TableToCSV(ii).raw_H=y';

TableToCSV(ii).FStat=a{ii}.FStat(2);
TableToCSV(ii).DF1=a{ii}.DF1(2);
TableToCSV(ii).DF2=a{ii}.DF2(2);
TableToCSV(ii).p_val=a{ii}.pValue(2);

%SS_effect = a{ii}.SumSq(1); % Sum of Squares for the effect
%SS_error = a{ii}.SumSq(end); % Sum of Squares for the error
%eta_squared(ii) = SS_effect / (SS_effect + SS_error);

%if p_val(ii)<0.0022
   % f=figure('Color',[1 1 1],'Position',[460 429 885 326]);
   % plot_across_time(firstG,secondG,ii)
   % if strcmpi('wake', WSA)
   % savefig(f,[fieldname '_wake_' num2str(ii)],'compact')
   % else
   %        savefig(f,[fieldname '_sleep_' num2str(ii)],'compact')
   % end
   % close all
 % if ii==8 && i==6
% plot_across_time(firstG,secondG,ii)
% elseif ii==6 && i==7
%     plot_across_time(firstG,secondG,ii)
% elseif ii==24 && i==8
%fprintf('feature %d \n' ,ii);
%title([fieldname ' ' num2str(a.pValue(2)) ' ' var_names(ii)])
% end
end
%sum(p_val<0.0021)
if strcmpi('wake',WSA)
save([ fieldname '_wake_table_supp_prc1585.mat'],'TableToCSV');
else
save([ fieldname '_sleep_table_supp_prc1585.mat'],'TableToCSV');
end
%[sorted,idx]=sort(p_val) ;
end


function plot_across_time(firstG,secondGroup,d)

timings=min([size(firstG,1),size(secondGroup,1)]);

firstG=firstG(1:timings,:);
secondGroup=secondGroup(1:timings,:);

for i=1:size(firstG,1)
    [~,test_p(i)]=ttest2(firstG(i,:),secondGroup(i,:));
end

A=mean(firstG,2);
B=mean(secondGroup,2);

SEM_A=std(firstG,0,2)/sqrt(size(firstG,2));
SEM_B=std(secondGroup,0,2)/sqrt(size(secondGroup,2));

load('/Users/worg/Documents/identificationPapar/vars.mat');

% if d>24
%  param = [vars{d-24} ' Sleep'];
%  unit=add_unit24(d-24);
% else
 param = [var_names{d}];
 unit=add_unit25(d);
% end    
time = [5:5:timings*5];
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
        xticks([1:60:time(end)*5]);
    xticklabels([0:60:time(end)*5]);
    xlabel('Time (minutes)');
    param = regexprep(param,'_',' ');
    ylabel([param ' ' unit]);
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
subjects=[];
TimePoints=[];
y=[];
    for i = 1:length(values1_L)
    sizes(i) = size(values1_L{i},1); % Store size of each table
    end
    
    %           if ismember(ii,[1 2 5 6 9 10])
    % load('/Users/worg/Documents/calibration_ADinst_Holter/calibrations_fitresults.mat')
    %           end
   
        lengths = min(sizes);
            for j=1:num_tables
mean_val_1L=table2array(values1_L{j}(:,ii));
mean_val_1L(isnan(mean_val_1L))=[];
    %         if ismember(ii,[1 2 5 6 9 10])
    % mean_val_1L=fitresult.p1*mean_val_1L + fitresult.p2;
    %         end
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

function [allVectors,averageVector,stdVector]=prepare_mm(C)    

  for i = 1:length(C)
    sizes(i) = size(C{i},1); % Store size of each table
end
        maxLength = min(sizes);

for i = 1:length(C)
    currentLength = length(C{i});
    
    if currentLength < maxLength
        % Pad with NaNs (or zeros, depending on your preference)
        C{i} = [C{i}; zeros(maxLength - currentLength,1)];
    elseif currentLength > maxLength
        % Truncate the vector
        C{i} = C{i}(1:maxLength);
    end
end
allVectors = cell2mat(C);

% Compute the average vector, ignoring NaNs
averageVector = mean(allVectors, 2, 'omitnan');
stdVector = std(allVectors,0,2);

end

