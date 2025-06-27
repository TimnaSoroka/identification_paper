%% supp2- correlation timings

load('corr_self_accdata_old.mat')
x(x(:,1)==0,1)=nan;
x(x(:,2)==0,2)=nan;

figure("Color",[1 1 1])
scatter(x(:,1),x(:,2), 'MarkerFaceColor','#D3D3D3',...
                'MarkerEdgeColor',[0.5 .5 .5],...
                'SizeData',80);
h2=lsline();
h2.LineWidth = 3;

h2.Color = 'k';
corr(x(:,1),x(:,2),'rows','complete')
set(gca,'FontSize',15)
xlim([0 12])
ylim([0 12])
xlabel('Self Reported Sleep Duration (Hours)') 
ylabel('Accelerometer Driven leep Duration (Hours)') 