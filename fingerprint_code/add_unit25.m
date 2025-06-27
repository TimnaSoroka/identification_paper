function [units] =add_unit25(i)

if ismember(i,[11:17,20:23])
    units='(ratio)';
elseif ismember(i,[1,2])
    units='(L)';
elseif ismember(i,[5,6,9])
    units='(L/s)';
elseif ismember(i,10)
    units='(L/min)';
elseif ismember(i,[3,4,18,19])
    units='(sec)';
elseif ismember(i,[7,8])
    units='(Breath/sec)';
    elseif ismember(i,[24,25])
    units='(%)';
else
    units= '';
end

end