%% Generate matlab versions of the data so we can load fast
clear;
clc;

if(ispc)
    folder = 'C:\\Users\\Kiran\\ownCloud\\PhD\\sim_results\\arrhythmia';
elseif(ismac)
    folder = '/Users/Kiran/ownCloud/PhD/sim_results/arrhythmia';
else
    folder = '/home/kiran/ownCloud/PhD/sim_results/arrhythmia';
end
inputFname = 'arrhythmia.data';
outputFname = 'arrhythmia.mat';
X = import_arrhythmia(fullfile(folder,inputFname));
save(fullfile(folder,outputFname),'X');

%% setup the data
clear;
clc;
dbstop if error;

% user configuration for which dataset we want to process
dataset = 'arrhythmia';

if(ispc)
    folder = 'C:\\Users\\Kiran\\ownCloud\\PhD\\sim_results';
elseif(ismac)
    folder = '/Users/Kiran/ownCloud/PhD/sim_results';
else
    folder = '/home/kiran/ownCloud/PhD/sim_results';
end

load(fullfile(folder,dataset,strcat(dataset,'.mat')));

% drop NA columns
y = X(:,end); X = X(:,1:end-1); 
[row, col] = find(isnan(X));
nancols = unique(col);
X(:,nancols) = [];

%% Test the mRMR algorithm on various estimators of MI for different datasets

% setup the estimators of MI
minScanIncr = 0.015625;
knn_1 = 1;
knn_6 = 6;
knn_20 = 20;

functionHandlesCell = {@ktau_mi;
                       @KraskovMI_cc_mex;
                       @KraskovMI_cc_mex;
                       @KraskovMI_cc_mex;
                       @vmeMI_interface;
                       @apMI_interface;
                       @cim_mi;};
functionArgsCell    = {{};
                       {knn_1};
                       {knn_6};
                       {knn_20};
                       {};
                       {};
                       {minScanIncr};};
fNames = {'ktau','knn_1','knn_6','knn_20','vme','ap','cim'};
                   
% % some tests to make sure that the serial and parallel versions of the
% % algorithm produce the same results
% testIdx = 2;
% K = 50;
% t1 = cputime;
% fea1 = mrmr_mid_serial(X, y, K, functionHandlesCell{testIdx}, functionArgsCell{testIdx})
% t2 = cputime;
% fea2 = mrmr_mid(X, y, K, functionHandlesCell{testIdx}, functionArgsCell{testIdx})
% t3 = cputime;
% fprintf('SerialTime=%0.02f ParallelTime=%0.02f equal?=%d\n',t2-t1,t3-t2,isequal(fea1,fea2));

numFeaturesToSelect = 50;

for ii=1:length(fNames)
    fs_outputFname = strcat(dataset,'_fs_',fNames{ii},'.mat');
    fOut = fullfile(folder,dataset,fs_outputFname);
    fprintf('Processing %s -- %s\n',fNames{ii},fOut);
    % if file exists, don't re-do it!
    if(~exist(fOut,'file'))
        featureVec = mrmr_mid(X, y, numFeaturesToSelect, functionHandlesCell{ii}, functionArgsCell{ii});
        save(fOut,'featureVec');
    end
end