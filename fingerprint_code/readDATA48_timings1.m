function [values,labels,vars]=readDATA48_timings(QA,fieldname,timings,start)

stop=start+timings/5-1;

    labels={QA.(fieldname)};

            values1={QA.Data_wake};
            values2={QA.Data_sleep};

            for i=1:size(values1,2)
 if size(values1{1,i},1)<stop
    % fprintf('subj %s were wake less than %s minutes- mean of %s were calculated \n', num2str(i), num2str(timings), num2str(size(values2{1,i},1)*5))
                mean_values1(i,:)=mean(values1{1,i},'omitmissing');

 else
                                  mean_values1(i,:)=mean(values1{1,i}(start:stop,:),'omitmissing');

 end
            end

                        for i=1:size(values2,2)
 if size(values2{1,i},1)<stop
     %fprintf('subj %s sleep less than %s minutes- mean of %s were calculated \n', num2str(i), num2str(timings), num2str(size(values2{1,i},1)*5))
                  mean_values2(i,:)=mean(values2{1,i},'omitmissing');
 else
                mean_values2(i,:)=mean(values2{1,i}(start:stop,:),'omitmissing');
 end
            end

        data_to_erase=cell2mat(cellfun(@isempty,labels,'UniformOutput',false));

        labels=cell2mat(labels);

        mean_values1(data_to_erase,:)=[];
        mean_values2(data_to_erase,:)=[];

mean_values1(:,17)=[];
mean_values2(:,17)=[];

nan_to_rm=isnan(labels);
labels(nan_to_rm)=[];
mean_values1(nan_to_rm,:)=[];
mean_values2(nan_to_rm,:)=[];

        vars=mean_values1.Properties.VariableNames;
        values=[table2array(mean_values1),table2array(mean_values2)];
        end