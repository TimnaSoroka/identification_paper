function plot_acc_id_HCTSA_timings_holdon(list_to_plot,list_to_plot2)

load([list_to_plot.folder '/' list_to_plot.name]);
mean_acc=[mean([x.acc_id_60]);mean([x.acc_id_120]);mean([x.acc_id_180]);nan;mean([x.acc_id_300]);nan;mean([x.acc_id])];
SEs=[std([x.acc_id_60]);std([x.acc_id_120]);std([x.acc_id_180]);nan;std([x.acc_id_300]);nan;std([x.acc_id])];

line=[60:60:540,100];

mean_acc(mean_acc==0)=nan;
SEs(mean_acc==0)=nan;

xl=num2cell(line);

%f = figure('Color', [1, 1, 1]);
plot(mean_acc,'o','MarkerSize',10,'MarkerFaceColor', 'none','MarkerEdgeColor', '#7f3f98')
hold on
%plot(ll,yi,'k')
n=48;
errorbar(mean_acc, SEs,  'color' , '#7f3f98','linewidth' , 1.2); %'lineStyle' , 'none',
  xticks(1:10)
 %xlim([60 6000])
 xticklabels({60:60:540, 'full'})
ylim([0,100])
yline(1/n,'r--','LineWidth',3,'DisplayName','Chance')
%yticks(50:20:100)
xlabel('Time (minutes)')
ylabel('Accuracy (%)')
set(gca,'FontSize',12)

%list_to_plot2=dir('/Users/worg/Documents/identificationPapar/result_BM_same_day/*wake*5min_blocks_0.65_*min*no_overlap_97.mat');
%list_to_plot=dir('/Users/worg/Documents/identificationPapar/result_BM_between_days/*wake*no_overlap_42.mat');

n=48;%chance=1/97*100;

acc_normed=[];
acc_not=[];
prc_not=[];
prc_normed=[];
i=1;
load([list_to_plot2(i).folder '/' list_to_plot2(i).name ]);
mean_acc2=[mean([x.acc_id_60]);mean([x.acc_id_120]);mean([x.acc_id_180]);nan;nan;mean([x.acc_id_360]);nan;nan;mean([x.acc_id_540]);mean([x.acc_id])];
SEs2=[std([x.acc_id_60]);std([x.acc_id_120]);std([x.acc_id_180]);nan;nan;std([x.acc_id_360]);nan;nan;std([x.acc_id_540]);std([x.acc_id])];

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
plot(mean_acc2,'o','MarkerSize',10,'MarkerFaceColor','none', 'MarkerEdgeColor',[0.5 0.75 1])
errorbar(mean_acc2, SEs2,  'color' , [ 0.5 0.75 1] ,'lineStyle' , 'none','linewidth' , 1.2); %,
plot(i1,mean_acc2,linspace(i1(1),i1(end),1000),out,'linewidth' , 2,'Color',[0.5 0.75 1],'DisplayName','Wake');
plot(ii1,mean_acc,linspace(ii1(1),ii1(end),1000),out1,'linewidth' , 2,'Color','#7f3f98','DisplayName','Sleep'); 
%  xticks(1:size(xl2,2))
 % xticklabels({xl2(1:end-1), 'full'})

end