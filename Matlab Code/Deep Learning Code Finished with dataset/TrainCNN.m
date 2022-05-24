%% Transfer Learning using AlexNet  
PathToData = 'C:\Users\jackg\OneDrive\Documents\MATLAB\Digital_Signal_Processing\deep_learning\ecgdataset';
PathToTest = 'C:\Users\jackg\OneDrive\Documents\MATLAB\Digital_Signal_Processing\deep_learning\ecgTest';

TrainImageDataStore = imageDatastore(PathToData,'IncludeSubfolders',true,'LabelSource','foldernames');
TestImageDataStore = imageDatastore(PathToTest,'IncludeSubfolders',true,'LabelSource','foldernames');


TrainingImages = shuffle(TrainImageDataStore);
TestImages = shuffle(TestImageDataStore);

% remaining test data is defined as Test images

CNN = alexnet; % AlexNet used as CNN for Transfer Learning  
layersToChange = CNN.Layers(1:end-3); %keep all layer bar last 3 to train classifier 
numClasses = 3; % define number of classes (ARR,CHF, NSR)

layers = [          % define the layers in Alexnet 
    layersToChange
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)    %20,20
    softmaxLayer
    classificationLayer];

TrainOptions= trainingOptions('sgdm',...  %define the diffferent training options 
    'MiniBatchSize',49,...
    'MaxEpochs',5, ...
    'InitialLearnRate',1e-4,...
    'Shuffle','every-epoch',...
    'ValidationData',TestImages,...
    'ValidationFrequency',10,...
    'Verbose',false,...
    'Plots','training-progress');

TransferTrainNetwork = trainNetwork(TrainingImages,layers,TrainOptions); %apply the training images, the altered layers and options
                                                                         % to train the network 
                                                        
Classification = classify(TransferTrainNetwork,TestImages);              %Make predictions (Classify) 
ValidationData = TestImages.Labels;                                      % define validation data with the correct laybels 
Accuracy = sum(Classification == ValidationData)/numel(ValidationData);  %calculate the accuracy 

plotconfusion(ValidationData, Classification)                            % plot the confusion matrix 