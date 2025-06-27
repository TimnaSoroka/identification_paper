function [units] =add_unit24(i)

if ismember(i,[10:16,19:22])
    units='(ratio)';
elseif ismember(i,[1,2])
    units='(L)';
elseif ismember(i,[5,6,8])
    units='(L/s)';
elseif ismember(i,9)
    units='(L/min)';
elseif ismember(i,[3,4,18,17])
    units='(sec)';
elseif ismember(i,[7])
    units='(Breath/sec)';
    elseif ismember(i,[24,23])
    units='(%)';
else
    units= '';
end

end