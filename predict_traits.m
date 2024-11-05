
clear
close all
%rng(5687)
rng(10)

addpath '/Users/worg/Documents/identificationPapar/demographic'

directory_to_use='/Users/worg/Documents/identificationPapar/'; %/Users/timnas/Documents/projects/24h_recordings/NC_24Hours_Analysis/
load([directory_to_use 'predict_AQ_BECK_TA/QA_updated5.mat'])
QA=AllSubjData(1:97);
clearvars p p_edge

for f=6
          figure; %     subplot(3,1,f-5)
   ff=fieldnames(QA);
fieldname=ff{f};
timings=1200;
start=1;
[XX,labels,vars]=readDATA48_timings1(QA,fieldname,timings,start);

XX=convert_calibrated_units48(XX);
for i=1:size(vars,2)
vars48{i}=[vars{i} ' wake'];
vars48{i+24}=[vars{i} ' sleep'];
end

for i=1:size(XX,2)

        secondG=XX(:,i);
        secondG(secondG<mean(secondG,'omitmissing')-3.5*std(secondG,'omitmissing'))=nan;
        secondG(secondG>mean(secondG,'omitmissing')+3.5*std(secondG,'omitmissing'))=nan;

        XX(:,i)=secondG;
        secondG=[];

           [R_corr(i), p_corr(i)] = corr(labels', XX(:,i),'rows','complete','type','Spearman');

    end

    qq=p_corr<0.05;
X=XX(:,qq);
y=labels;

switch fieldname
     case 'TA'
       [predicted_val,R_squared]=leastsquares_regg(X,y);
          predicted_val=predicted_val';
    case 'AQ'   
  %  [predicted_val,R_squared]=coarse_gause_SVM(X,y);
       [predicted_val,R_squared]=linear_SVM(X,y);
          predicted_val=predicted_val';

    otherwise
         [predicted_val,R_squared]=linear_leaveout(X,y);
predicted_val=predicted_val+abs(0-min(predicted_val));
end

[R,p]=corr(predicted_val,y','rows','complete','type','Spearman');


scatter(predicted_val,y','MarkerFaceColor','#D3D3D3',...
                'MarkerEdgeColor',[0.5 .5 .5],...
                'SizeData',80);
h2=lsline();
h2.LineWidth = 3;
h2.Color = 'k';
set(gca, 'FontSize',15)
xlabel(['Prdicted ' upper(fieldname) ' Score'])
ylabel(['Actual ' upper(fieldname) ' Score'])
min_axes=min([min(predicted_val),min(y)]);
max_axes=max([max(predicted_val),max(y)]);

% xlim([min_axes max_axes])
% ylim([min_axes max_axes])
print_results=1;


A=XX(:,qq);
A_normalized = A ./ max(A); % Normalize by the maximum of each column

% A_normalized = A ./ sum(A); % Uncomment this line to normalize by the sum

% Sum the normalized matrix into a single vector
gneral_vector = sum(A_normalized, 2,'omitmissing');

disp(fieldname)
disp(R)
disp(p)
disp(find(qq))

end
function [predictions,R_square_adjusted]=linear_leaveout(X,y)
n = size(X, 1); % Number of observations
predictions = zeros(n, 1);
actuals = y; % Actual values

for i = 1:n
    % Split data into training and testing sets
    X_train = X;
    y_train = y;
    X_test = X(i, :);
    y_test = y(i);

   X_train(i,:)=[];
    y_train(i)=[];
    
    % Fit the linear regression model
    model = fitlm(X_train, y_train);
    R_square_adjusted(i)=model.Rsquared.Adjusted;
    % Make a prediction
    predictions(i) = predict(model, X_test);
end
end