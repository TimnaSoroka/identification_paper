function [subject,Time,values1_L]=prepare_anova_NC(values1_Low,names_long)

numCells = numel(values1_Low);
sizes = zeros(numCells, 1);  % Preallocate
Time=[];
for i = 1:numCells
    s = values1_Low{i};
    Time=[Time,1:numel(s)];
end

    bigStruct = vertcat([values1_Low{:}]);
values1_L=struct2table(bigStruct);
subject=vertcat(names_long{:});
