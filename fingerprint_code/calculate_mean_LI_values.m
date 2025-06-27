function[mean_values_all,excluded] =calculate_mean_LI_values(AllSubjData,directory_to_use,block_length,WSA,timings,start,normalize,overlap,cleaning,exclude_shorts)

for iii=1:length(timings)

mean_values=table();
subj_excluded=[];

time_to_check=timings(iii);
    time_in_blocks=round(time_to_check/block_length);   

for sbj=1:size(AllSubjData,2)
    SubjectName=AllSubjData(sbj).Name;
%    SubjectName=AllSubjData(sbj).Code;

    if normalize
        file=dir([ directory_to_use '/code/LI_parameters/SeparateNost_' num2str(block_length) 'min_blocks_per_subj/' SubjectName '/' SubjectName '_LI_params_' WSA '_*normalized.mat']);
    else
        file=dir([ directory_to_use '/code/LI_parameters/SeparateNost_' num2str(block_length) 'min_blocks_per_subj/' SubjectName '/' SubjectName '_LI_params_' WSA '_*p.mat']);
    end
    load([file.folder '/' file.name]);


    if overlap
        o=size(mat,2);
    else
        o=1;
    end

        for i=1:o

            if time_to_check==100
                x=struct2table(mat(:,o));
            elseif size(mat,1)-start+1<start+time_in_blocks-1
               if exclude_shorts
                    fprintf('subject %s were %s only %s hours, hence excluded for %s analysis \n', SubjectName,WSA,num2str((size(mat,1)*block_length)/60,2),num2str(time_to_check) )
                    subj_excluded=[subj_excluded,SubjectName];
                    continue
               else
                    x=struct2table(mat(:,o));
               end
            else
                x=struct2table(mat(start:time_in_blocks+start-1,o));
            end

        y=mean(x,'omitmissing');
        s=std(x,0,1,'omitmissing');
        if cleaning
            st=table2array(s);
            yy=table2array(y);
            xx=table2array(x);
            var_names=x.Properties.VariableNames;
            xx(xx>2.5*st+yy | xx<yy-2.5*st)=nan;
            y_=mean(xx,'omitmissing');
            y_c=array2table(y_,"VariableNames",var_names);
            mean_values=[mean_values;y_c];
        else
            mean_values=[mean_values;y];
        end
        end
  end
mean_values_all{iii}=mean_values;
end
excluded{iii}=subj_excluded;
end