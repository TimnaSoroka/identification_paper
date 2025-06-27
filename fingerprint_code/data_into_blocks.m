function [raw_in_block]= data_into_blocks(block_length_in_minutes,sliding_window,Data_wake,SeparateNost,normalize,accelero,StartPoint,how_long)

if isstruct(Data_wake)
    Data_wake=Data_wake.Data_wake;
end

if exist('how_long','var')
    X=how_long;
else
    StartPoint=1;
    X=length(Data_wake);
end

if SeparateNost
    if size(Data_wake,2)==2
        raw_data=Data_wake(StartPoint:end,:);
    else
    raw_data=Data_wake(StartPoint:end,[2,4]);
    end
else
    if size(Data_wake,2)==2 
        raw_data=Data_wake(StartPoint:end,:);
        raw_data(:,2)=-raw_data(:,2);
                raw_data=raw_data(StartPoint:end,1)+raw_data(StartPoint:end,2);
    elseif isstruct(Data_wake)
  raw_data=Data_wake.fieldValue(StartPoint:end,:);
        raw_data(:,2)=-raw_data(:,2);
                raw_data=raw_data(StartPoint:end,1)+raw_data(StartPoint:end,2);
    elseif accelero
    raw_data=Data_wake(StartPoint:end,:);
    else
   raw_data=Data_wake(StartPoint:end,[2 4]);
      raw_data=Data_wake(StartPoint:end,2)+Data_wake(StartPoint:end,4);
    end  
end
% respirationData=Data_wake(:,2)+Data_wake(:,4);

if normalize
    raw_data=zscore(raw_data);
end

block_length = block_length_in_minutes*6*60;
n_blocks = floor(size(raw_data, 1) / block_length);

raw_in_block = cell(1, n_blocks);   % Preallocate cell array

for i = 1:n_blocks
    idx_start = (i - 1) * block_length + 1;
    idx_end = i * block_length;
    raw_in_block{i} = raw_data(idx_start:idx_end, :);  % Each is 1800 × 2
end
