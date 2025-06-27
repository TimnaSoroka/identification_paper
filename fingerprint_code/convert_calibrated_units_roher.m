function [full_time_mean_wake_values]=convert_calibrated_units(full_time_mean_wake_values)
%input is zelano table

load('/Users/worg/Documents/calibration_ADinst_Holter/calibrations_Roher.mat')
        for row=1:size(full_time_mean_wake_values,1)
            for column=1:size(full_time_mean_wake_values,2)
x=table2array(full_time_mean_wake_values(row,column));
xx=sqrt(abs(x));
converted_wake(row,column)=k_fit*xx.^2;
            end
        end
        converted_wake=array2table(converted_wake);
        full_time_mean_wake_values(:,[1 2 5 6 9 10])=converted_wake(:,[1 2 5 6 9 10]);
        end