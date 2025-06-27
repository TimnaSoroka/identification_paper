function [values,labels,vars]=readDATA50(QA,fieldname)

    labels={QA.(fieldname)};

            values1={QA.mean_wake};
            values2={QA.mean_sleep};


        data_to_erase=cell2mat(cellfun(@isempty,labels,'UniformOutput',false));

        labels=cell2mat(labels);

        values1(data_to_erase)=[];
        values2(data_to_erase)=[];

        val_table1=[values1{1}];
        val_table2=[values2{1}];

        for i=2:size(values1,2)
            val_table1=[val_table1;values1{i}];
            val_table2=[val_table2;values2{i}];
        end

% val_table1(:,7)=[];
% val_table2(:,7)=[];

nan_to_rm=isnan(labels);
labels(nan_to_rm)=[];
val_table1(nan_to_rm,:)=[];
val_table2(nan_to_rm,:)=[];


       vars=val_table1.Properties.VariableNames;
        values=[table2array(val_table1),table2array(val_table2)];
        end