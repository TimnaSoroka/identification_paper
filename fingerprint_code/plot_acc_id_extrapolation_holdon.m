function plot_acc_id_extrapolation_holdon(list_to_plot,list_to_plot2)
%'acc_id_zelano_wake_5min_blocks_0.65_120min_no_overlap_normalized.mat'

% list_to_plot=dir('/Users/worg/Documents/identificationPapar/result_BM_between_days/extrapolation_results_wake.mat');
% list_to_plot2=dir('/Users/worg/Documents/identificationPapar/result_BM_between_days/extrapolation_results_sleep.mat');

% list_to_plot=dir('/Users/worg/Documents/identificationPapar/result_BM_same_day/extrapolation_results_wake.mat');
% list_to_plot2=dir('/Users/worg/Documents/identificationPapar/result_BM_same_day/extrapolation_results_sleep.mat');

load([list_to_plot.folder '/' list_to_plot.name])
% acc_normed=[];
% acc_not=[];
% prc_not=[];
% prc_normed=[];
% 
% for i=1:size(list_to_plot,1)
% name=list_to_plot(i).name;
% x=regexp(name,'min');
% recording_length=name(x(2)-3:x(2)-1);
% slash=regexp(recording_length,'_');
% recording_length(slash)=[];
% timings(i)=str2double(recording_length);
% 
% load([list_to_plot(i).folder '/' list_to_plot(i).name ]);
mean_acc=mean(acc_id_per_extrapolation);
std_acc=std(acc_id_per_extrapolation);
%SEs=std_acc./sqrt(size(acc_id_per_extrapolation,1)-1);
SEs=std_acc;

% end

% tmp=regexpi({list_to_plot.name},'normalized');
% n=cellfun(@isempty,tmp);


% mean_acc=mean_acc(n);
% SEs=SEs(n);
% timings=prc_num(n);

% mean_acc=mean_acc(~n);
% SEs=SEs(~n);
% timings=prc_num(~n);

% [~,idx]=sort(timings);
% full=ismember(timings(idx),100);
% idx_new=[idx,idx(full)];
% idx_new(find(full))=[];
% xl=num2cell(timings(idx_new));
% xl={xl, ' full'};

for i=1:size(subj_list,2)
n_extra(i)=size(subj_list{1,i},2);
chance(i)=1/n_extra(i)*100;
end

%f = figure('Color', [1, 1, 1]);
plot(mean_acc,'o','MarkerSize',10,'MarkerFaceColor','none', 'MarkerEdgeColor',[0.5 0.75 1])
hold on
errorbar(mean_acc, SEs,  'color' , [0.5 0.75 1],'linewidth' , 2); %'lineStyle' , 'none',
plot(chance,'r--','MarkerSize',10,'MarkerFaceColor','none', 'MarkerEdgeColor','auto','linewidth' , 2)
xl=n_extra;
  xticks(1:size(xl,2))
 xticklabels(xl)
ylim([0,100])
% yline(0.01,'r--','LineWidth',1.2)
%yticks(50:20:100)
xlabel('#Participants')
ylabel('Accuracy (%)')
set(gca,'FontSize',15)

%f = figure('Color', [1, 1, 1]);
plot(mean_acc,'o','MarkerSize',10,'MarkerFaceColor','none', 'MarkerEdgeColor',[0.5 0.75 1])
hold on
errorbar(mean_acc, SEs,  'color' , [0.5 0.75 1],'linewidth' , 2); %'lineStyle' , 'none',
%plot(chance,'r--','MarkerSize',10)
xl=n_extra;
  xticks(1:size(xl,2))
 xticklabels(xl)
ylim([0,100])
% yline(0.01,'r--','LineWidth',1.2)
%yticks(50:20:100)
xlabel('#Participants')
ylabel('Accuracy (%)')
set(gca,'FontSize',12)

%list_to_plot2=dir('/Users/worg/Documents/identificationPapar/result_BM_same_day/extrapolation_results_sleep.mat');

load([list_to_plot2.folder '/' list_to_plot2.name])
mean_acc=mean(acc_id_per_extrapolation);
std_acc=std(acc_id_per_extrapolation);
%SEs=std_acc./sqrt(size(acc_id_per_extrapolation,1)-1);
SEs=std_acc;

plot(mean_acc,'o','MarkerSize',10,'MarkerFaceColor','none', 'MarkerEdgeColor','#7f3f98')
hold on
errorbar(mean_acc, SEs,  'color' , '#7f3f98','linewidth' , 1.2); %'lineStyle' , 'none',

end