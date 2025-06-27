function plot_acc_id_timings_holdon(list_to_plot,list_to_plot2)

%BM-no_overlap,not normalized

%list_to_plot=dir('/Users/worg/Documents/identificationPapar/result_BM_same_day/*sleep*5min_blocks_0.65_*min*no_overlap_97.mat');
%list_to_plot=dir('/Users/worg/Documents/identificationPapar/result_BM_between_days/*sleep*no_overlap_42.mat');

n=str2num(list_to_plot(1).name(end-5:end-4));%chance=1/97*100;

acc_normed=[];
acc_not=[];
prc_not=[];
prc_normed=[];

line=[60:60:540,100];

for i=1:size(list_to_plot,1)
name=list_to_plot(i).name;
x=regexp(name,'min');
recording_length=name(x(2)-3:x(2)-1);
slash=regexp(recording_length,'_');
recording_length(slash)=[];
timings=str2double(recording_length);
loc=find(timings==line);


load([list_to_plot(i).folder '/' list_to_plot(i).name ]);
mean_acc(loc)=mean(acc_id);
   mean_std(loc)=mean(std(acc,0,2))*100;
    %SEs(loc)=mean_std(i)./sqrt(size(acc_id,2)-1);
        SEs(loc)=mean_std(loc);
end

mean_acc(mean_acc==0)=nan;
SEs(mean_acc==0)=nan;

mean_acc(7)=mean_acc(end);
mean_acc(8:10)=[];
SEs(7)=SEs(end);
SEs(8:10)=[];
% ll=mean_acc;
% nnn=find(isnan(ll));
% for i=1:length(nnn)

xl=num2cell(line);

%f = figure('Color', [1, 1, 1]);
plot(mean_acc,'ko','MarkerSize',10,'MarkerFaceColor','none')
hold on
%plot(ll,yi,'k')

errorbar(mean_acc, SEs,  'color' , '#7f3f98','linewidth' , 1.2); %'lineStyle' , 'none',
  xticks(1:10)
 %xlim([60 6000])
 xticklabels({60:60:540, 'full'})
ylim([0,100])
yline(1/n,'r--','LineWidth',3,'DisplayName','Chance')
%yticks(50:20:100)
xlabel('Time (minutes)')
ylabel('Accuracy (%)')
set(gca,'FontSize',15)

%list_to_plot2=dir('/Users/worg/Documents/identificationPapar/result_BM_same_day/*wake*5min_blocks_0.65_*min*no_overlap_97.mat');
%list_to_plot=dir('/Users/worg/Documents/identificationPapar/result_BM_between_days/*wake*no_overlap_42.mat');

n=str2num(list_to_plot2(1).name(end-5:end-4));%chance=1/97*100;

acc_normed=[];
acc_not=[];
prc_not=[];
prc_normed=[];

for i=1:size(list_to_plot2,1)
name=list_to_plot2(i).name;
x=regexp(name,'min');
recording_length=name(x(2)-3:x(2)-1);
slash=regexp(recording_length,'_');
recording_length(slash)=[];
timings=str2double(recording_length);
loc=find(timings==line);
if strcmpi(name(end-9:end-4),'capped')
    loc=7;
end
load([list_to_plot2(i).folder '/' list_to_plot2(i).name ]);
mean_acc2(loc)=mean(acc_id);
   mean_std2(loc)=mean(std(acc,0,2))*100;
    % SEs2(loc)=mean_std(i)./sqrt(size(acc_id,2)-1);
    SEs2(loc)=mean_std2(loc);
end

mean_acc2(mean_acc2==0)=nan;
SEs2(mean_acc2==0)=nan;


inn = ~isnan(mean_acc2);
i1 = (1:numel(mean_acc2)).';
pp = interp1(i1(inn),mean_acc2(inn),'linear','pp');
out = fnval(pp,linspace(i1(1),i1(end),1000));


inn = ~isnan(mean_acc);
ii1 = (1:numel(mean_acc)).';
pp1 = interp1(ii1(inn),mean_acc(inn),'linear','pp');
out1 = fnval(pp1,linspace(ii1(1),ii1(end),1000));

% [~,idx]=sort(timings);
% full=ismember(timings(idx),100);
% idx_new=[idx,idx(full)];
% idx_new(find(full))=[];

% xl={xl, ' full'};

% num_success=(mean_acc(idx_new)/100*n);
% num_trails=n;

hold on
plot(mean_acc2,'ko','MarkerSize',10,'MarkerFaceColor','none', 'MarkerEdgeColor','k')
errorbar(mean_acc2, SEs2,  'color' , 'k' ,'lineStyle' , 'none','linewidth' , 1.2); %,
plot(i1,mean_acc2,linspace(i1(1),i1(end),1000),out,'linewidth' , 2,'Color','k','DisplayName','Wake');
plot(ii1,mean_acc,linspace(ii1(1),ii1(end),1000),out1,'linewidth' , 2,'Color','#7f3f98','DisplayName','Sleep'); 
%  xticks(1:size(xl2,2))
 % xticklabels({xl2(1:end-1), 'full'})

end