%% wake sleep comparison and classification
%% for the unit plot figure- change to true->plot_units_plot_fig
%% for the timings figure- change to true->plot_timings_fig
%% for the scatter3 figure- change to true->plot_scatter3_fig

close all
clear
save_results=0;
%% this code should run after

% parameters:
WSA='wake';
block_length=5;
cleaning=false;
overlap=false;
normalize=false;
exclude_shorts=false;
directory_to_use='/Users/worg/Documents/identificationPapar';

%timings=[5,30,60,180,300,100];
timings=100;
start=15;
plot_units_plot_fig=1;
plot_timings_fig=0;
plot_scatter3_fig=0;
classification=1;
%parameters=[9,10,29];
%parameters=[8,28,14,11,12,15];%22
load("/Users/worg/Documents/github_repo/sleep_wake/Results_WS30params_MCFS_.mat")
parameters=[{[9 10 29]}]%,{[8 9 10 11 28 29]}]%,{Result(1:3)'},{Result(1:7)'},[3,8,11,15,18]];%[1:30];
%parameters=Result.Ranking(1:5);%[1:30];

%% choose subjects:
load([ directory_to_use '/AllSubjData.mat']);

subject_to_use=importdata([ directory_to_use '/SubjectsToUse.xlsx']);
subject_to_use=subject_to_use.all_subj;

subjectsNamesToRemoveFromNasalCycleAnalysis=setdiff({AllSubjData.Name},subject_to_use);
% subjectsNamesToRemoveFromNasalCycleAnalysis = setdiff({allAnalysisFields(strcmp({allAnalysisFields.Group}, 'ADHD')).SubjectName}, 'AKS229_rit1');
subjectsIndicesToRemoveFromNasalCycleAnalysis = cellfun(@(str) any(strcmp(str, subjectsNamesToRemoveFromNasalCycleAnalysis)), {AllSubjData.Name});
AllSubjData = AllSubjData(~subjectsIndicesToRemoveFromNasalCycleAnalysis);

% %%
% prepare_blocks_per_subject(directory_to_use,AllSubjData,WSA,normalize,SeparateNost,block_length_in_minutes,sliding_window_in_minutes,train_by_hours,prc_train,UseSelfReportedTimings)
% fprintf('prepared all raw data into blocks\n')
%
% create_BM_per_sbj(directory_to_use,AllSubjData,SeparateNost,WSA,normalize,block_length_in_minutes)
% fprintf('BM parameters were calculated for all data blocks\n')
%

%SeparateNost=true;
% prepare_blocks_per_subject(directory_to_use,AllSubjData,WSA,normalize,SeparateNost,block_length_in_minutes,sliding_window_in_minutes,train_by_hours,prc_train,UseSelfReportedTimings)
% fprintf('prepared all raw data into blocks\n')
%
% create_BM_per_sbj(directory_to_use,AllSubjData,SeparateNost,WSA,normalize,block_length_in_minutes)
% fprintf('BM parameters were calculated for all data blocks\n')

%%
[mean_wake_values,shorts_wake]=calculate_mean_BM_values(AllSubjData,directory_to_use,block_length,WSA,timings,start,normalize,overlap,cleaning,exclude_shorts);
mean_LI_wake_values=calculate_mean_LI_values(AllSubjData,directory_to_use,block_length,WSA,timings,start,normalize,overlap,cleaning,exclude_shorts);

WSA='sleep';
[mean_sleep_values,shorts_sleep]=calculate_mean_BM_values(AllSubjData,directory_to_use,block_length,WSA,timings,start,normalize,overlap,cleaning,exclude_shorts);
mean_LI_sleep_values=calculate_mean_LI_values(AllSubjData,directory_to_use,block_length,WSA,timings,start,normalize,overlap,cleaning,exclude_shorts);

var_names=[mean_wake_values{1,1}.Properties.VariableNames,mean_LI_wake_values{1,1}.Properties.VariableNames];

for iii=1:size(mean_sleep_values,2)

    mean_w_values_array=[table2array(mean_wake_values{iii}),table2array(mean_LI_wake_values{iii})];
    mean_s_values_array=[table2array(mean_sleep_values{iii}),table2array(mean_LI_sleep_values{iii})];

    if cleaning
        m=mean(mean_w_values_array,'omitmissing');
        s=std(mean_w_values_array,'omitmissing');
        mean_w_values_array(mean_w_values_array>2.5*s+m | mean_w_values_array<m-2.5*s)=nan;
        m_mean_w_values{iii}=array2table(mean(mean_w_values_array,'omitmissing'),'VariableNames',var_names);

        m=mean(mean_s_values_array,'omitmissing');
        s=std(mean_s_values_array,'omitmissing');
        mean_s_values_array(mean_s_values_array>2.5*s+m | mean_s_values_array<m-2.5*s)=nan;
        m_mean_s_values{iii}=array2table(mean(mean_s_values_array,'omitmissing'),'VariableNames',var_names);
    else
        % m_mean_w_values{iii}=mean(mean_wake_values{iii});
        % m_mean_s_values{iii}=mean(mean_sleep_values{iii});
        m_mean_w_values{iii}=[mean(mean_wake_values{iii}),mean(mean_LI_wake_values{iii})];
        m_mean_s_values{iii}=[mean(mean_sleep_values{iii}),mean(mean_LI_sleep_values{iii})];

    end


    % X=[mean_w_values_array;mean_s_values_array];
    % save('/Users/worg/Documents/github_repo/Sleep_wake.mat','X');

    if classification

        mean_w_values_array(:,end+1)=deal(1);
        mean_s_values_array(:,end+1)=deal(2);

        for p=1:size(parameters,2)

            for ii=1:size(AllSubjData,2)

                testing=ii;
                training=setdiff(1:size(AllSubjData,2),testing);

                training_mat=[mean_s_values_array(training,1:end-1);mean_w_values_array(training,1:end-1)];
                testing_mat=[mean_s_values_array(testing,1:end-1);mean_w_values_array(testing,1:end-1)];
                training_labels=[mean_s_values_array(training,end);mean_w_values_array(training,end)];
                testing_labels=[mean_s_values_array(testing,end);mean_w_values_array(testing,end)];


                [mdl, validationAccuracyReal] = linearDisc(training_mat(:,parameters{p}),training_labels);
                labels_hat = mdl.predictFcn(testing_mat(:,parameters{p}));
                C = confusionmat(testing_labels,labels_hat);
                acc(ii) = sum(diag(C)) / sum(C(:));
                clearvars mdl
            end

            mean_acc(iii,p)=mean(mean(acc,2))*100;
            mean_std(iii,p)=mean(std(acc,0,2))*100;
            SEs(iii,p)=mean_std(iii,p)./sqrt(size(mean_s_values_array,1)-1);

        end
        mean_w_values_array(:,end)=[];
        mean_s_values_array(:,end)=[];

        if save_results
            save([ directory_to_use '/Figures/wake_sleep_timings'],"SEs","mean_acc","mean_std","timings","parameters");
        end
    end
end


%% figures
var_names = regexprep(var_names,'_',' ');

if plot_units_plot_fig
    if ismember(100,timings)
        full_time_mean_wake_values=[mean_wake_values{find(timings==100)},mean_LI_wake_values{find(timings==100)}];
        full_time_mean_sleep_values=[mean_sleep_values{find(timings==100)},mean_LI_sleep_values{find(timings==100)}];
        
        %%convert to flow units
[full_time_mean_wake_values]=convert_calibrated_units(full_time_mean_wake_values);
[full_time_mean_sleep_values]=convert_calibrated_units(full_time_mean_sleep_values);
        
full_time_mean_wake_values(:,7)=[];
full_time_mean_sleep_values(:,7)=[];
full_time_mean_wake_values(:,27)=[];
full_time_mean_sleep_values(:,27)=[];

f= figure('Position',[41 88 899 792],'Color',[1 1 1]);
        for i=1:12
            subplot(4,4,i)
            scatter(full_time_mean_wake_values{:,i},full_time_mean_sleep_values{:,i})
            min_val=min(min([full_time_mean_wake_values{:,i},full_time_mean_sleep_values{:,i}]));
            max_val=max(max([full_time_mean_wake_values{:,i},full_time_mean_sleep_values{:,i}]));
            hold on
            plot([min_val max_val],[min_val max_val],'k-')
            xlim([min_val max_val])
            ylim([min_val max_val])
            tit=[full_time_mean_sleep_values.Properties.VariableNames{i}];
            tit = regexprep(tit,'_',' ');
if contains(tit,'Percent')
                tit = regexprep(tit,'Percent','');
end
     units=add_unit24(i);
               ylabel([ tit ' ' units ' sleep'])
            xlabel([tit ' ' units ' wake'])
        end
        f= figure('Position',[41 88 899 792],'Color',[1 1 1]);
        for i=12+1:size(full_time_mean_wake_values,2)
            subplot(4,4,i-12)
            scatter(full_time_mean_wake_values{:,i},full_time_mean_sleep_values{:,i})
            min_val=min(min([full_time_mean_wake_values{:,i},full_time_mean_sleep_values{:,i}]));
            max_val=max(max([full_time_mean_wake_values{:,i},full_time_mean_sleep_values{:,i}]));
            hold on
            plot([min_val max_val],[min_val max_val],'k-')
            xlim([min_val max_val])
            ylim([min_val max_val])
            tit=[full_time_mean_sleep_values.Properties.VariableNames{i}];
            tit = regexprep(tit,'_',' ');
            if contains(tit,'Percent')
                tit = regexprep(tit,'Percent','');
end
            %title(tit)
           units=add_unit24(i);
                ylabel([ tit ' ' units ' sleep'])
            xlabel([tit ' ' units ' wake'])
                end
        % figure;
        % for i=1:size(full_time_mean_LI_wake_values,2)
        % subplot(1,5,i)
        % scatter(full_time_mean_LI_wake_values{:,i},full_time_mean_LI_sleep_values{:,i})
        % min_val=min(min([full_time_mean_LI_wake_values{:,i},full_time_mean_LI_sleep_values{:,i}]));
        % max_val=max(max([full_time_mean_LI_wake_values{:,i},full_time_mean_LI_sleep_values{:,i}]));
        % hold on
        % plot([min_val max_val],[min_val max_val])
        % xlim([min_val max_val])
        % ylim([min_val max_val])
        % tit=[full_time_mean_LI_sleep_values.Properties.VariableNames{i}];
        %     tit = regexprep(tit,'_',' ');
        % title([full_time_mean_LI_sleep_values.Properties.VariableNames{i}])
        % ylabel('sleep')
        % xlabel('wake')
        % end
        f1=figure('Color',[1 1 1],'Position',[57 436 943 262]);
        param=parameters{1};
        for i=1:length(param)
            subplot(1,length(param),i)
            scatter(full_time_mean_wake_values{:,param(i)},full_time_mean_sleep_values{:,param(i)},...
              'MarkerFaceColor',[0.5 .5 .5],...
              'MarkerEdgeColor','none',...
              'LineWidth',1);             %

            min_val=min(min([full_time_mean_wake_values{:,param(i)},full_time_mean_sleep_values{:,param(i)}]));
            max_val=max(max([full_time_mean_wake_values{:,param(i)},full_time_mean_sleep_values{:,param(i)}]));
            hold on
            plot([min_val max_val],[min_val max_val],'Color',[0.2 0.2 0.2],'LineWidth',1.5)
            xlim([min_val max_val])
            ylim([min_val max_val])
            %hold off
            [unit] =add_unit(param(i));
            tit=[full_time_mean_sleep_values.Properties.VariableNames{param(i)}];
            tit = regexprep(tit,'_',' ');
            %title(tit)
            ylabel([tit ' ' unit ' sleep'])
            xlabel([tit ' ' unit ' wake'])
            set(gca, 'FontSize',15)

            firstGroupValues = full_time_mean_wake_values{:,param(i)};
            secondGroupValues = full_time_mean_sleep_values{:,param(i)};

            [~, test_p, ~, test_stats] = ttest(firstGroupValues, secondGroupValues);
            EffectSize = meanEffectSize(firstGroupValues,secondGroupValues,'Effect','cohen',Paired=true);
            fprintf(['mean ' full_time_mean_sleep_values.Properties.VariableNames{param(i)} ' during wake: ' num2str(mean(firstGroupValues)) '±' num2str(std(firstGroupValues)) ...
                '\n and during sleep: ' num2str(mean(secondGroupValues)) '±' num2str(std(secondGroupValues)) '\n']);
            fprintf('ttest: t(%s)=%s, p=%s d=%s \n', num2str(test_stats.df), num2str(test_stats.tstat, 2), num2str(test_p),num2str(EffectSize.Effect));
        end

        for i=1:length(param)
            f2=figure('Color',[1 1 1],'Position',[892 492 108 206]);
            firstGroupValues = full_time_mean_wake_values{:,param(i)};
            secondGroupValues = full_time_mean_sleep_values{:,param(i)};

            y = [firstGroupValues,secondGroupValues];
            td_err_mean = std(y)/sqrt(size(y,1));
            bar(mean(y),'FaceColor','#C30010') %[0 0.3 0.5] '#C30010', '#FF964F'
            hold on
            errorbar(mean(y),td_err_mean,'LineStyle','none','color', [0.21 0.27 0.31],'linewidth' , 1.2);
            xticklabels({'wake' 'sleep'})
            set(gca, 'FontSize',15)
        end
    end
end

if plot_timings_fig && classification
    f = figure('Color', [1, 1, 1]);
    plot(mean_acc,'ko','MarkerSize',10,'MarkerFaceColor','black', 'MarkerEdgeColor','auto')
    hold on
    errorbar(mean_acc, SEs,  'color' , [0.21 0.27 0.31],'linewidth' , 1.2); %'lineStyle' , 'none',
    xl=[];
    for t=1:size(timings,2)-1
        xl=[xl;timings(t)];
    end
    yline(50,'r--','LineWidth',1.2)
    xl={xl, ' full'};
    xticks(1:size(xl{1,1},1)+1)
    xticklabels(xl)
    ylim([40,100])
    yticks(40:10:100)
    xlabel('Time (minutes)')
    ylabel('Accuracy (%)')
    set(gca,'FontSize',15)
end


%if size(parameters,2)>3
if plot_scatter3_fig
    if ismember(100,timings)
        if size(parameters{1},2)>=3
            full_time_mean_wake_values=mean_wake_values{find(timings==100)};
            full_time_mean_sleep_values=mean_sleep_values{find(timings==100)};
            full_time_mean_LI_wake_values=mean_LI_wake_values{find(timings==100)};
            full_time_mean_LI_sleep_values=mean_LI_sleep_values{find(timings==100)};

            [full_time_mean_wake_values]=convert_calibrated_units(full_time_mean_wake_values);
            [full_time_mean_sleep_values]=convert_calibrated_units(full_time_mean_sleep_values);


            full_wake=table2array([full_time_mean_wake_values,full_time_mean_LI_wake_values]);
            full_sleep=table2array([full_time_mean_sleep_values,full_time_mean_LI_sleep_values]);
            param=[29,10,8];
            f = figure('Color', [1, 1, 1]); %, 'Position', [640, 320, 740, 530]
            scatter3(full_sleep(:,param(1)),full_sleep(:,param(2)),full_sleep(:,param(3)),50,'filled');
            hold on
            scatter3(full_wake(:,param(1)),full_wake(:,param(2)),full_wake(:,param(3)),50,'filled','MarkerFaceColor','#C30010');
                        [units] =add_unit(param(1));
            xlabel([var_names{param(1)} ' ' units]);
                                   [units] =add_unit(param(2));
            ylabel([var_names{param(2)}  ' ' units]);
                                    [units] =add_unit(param(3));
            zlabel([var_names{param(3)} ' ' units]);
            set(gca,'FontSize',15)
            legend('sleep','wake','Location','northeast')
        end
    end
end