function [full_time_mean_wake_values]=convert_calibrated_units(full_time_mean_wake_values)
%input is zelano table

load('/Users/worg/Documents/calibration_ADinst_Holter/calibrations_fitresults.mat')
if istable(full_time_mean_wake_values)
    for row=1:size(full_time_mean_wake_values,1)
        for column=1:size(full_time_mean_wake_values,2)
            x=table2array(full_time_mean_wake_values(row,column));
            converted_wake(row,column)=fitresult.p1*x + fitresult.p2;
            converted_wake=array2table(converted_wake);
        end
    end
else
    converted_wake=fitresult.p1*full_time_mean_wake_values + fitresult.p2;
end


full_time_mean_wake_values(:,[1 2 5 6 8 9])=converted_wake(:,[1 2 5 6 8 9]);
end