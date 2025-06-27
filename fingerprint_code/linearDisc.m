function [trainedClassifier, validationAccuracy] = linearDisc(trainingData, responseData)

predictors = trainingData;
response = responseData;

% Train a classifier
% This code specifies all the classifier options and trains the classifier.
classificationDiscriminant = fitcdiscr(...
    predictors, ...
    response, ...
    'DiscrimType', 'pseudolinear', ...
    'Gamma', 0, ...
    'FillCoeffs', 'off');

% Create the result struct with predict function
predictorExtractionFcn = @(x) array2table(x);
discriminantPredictFcn = @(x) predict(classificationDiscriminant, x);
trainedClassifier.predictFcn = @(x) discriminantPredictFcn(predictorExtractionFcn(x));

% Add additional fields to the result struct
trainedClassifier.ClassificationDiscriminant = classificationDiscriminant;

% Perform cross-validation
partitionedModel = crossval(trainedClassifier.ClassificationDiscriminant); %, 'KFold', 5

% Compute validation accuracy
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
