%% Test the DrivFace dataset
clear;
clc;
dbstop if error;

if(ispc)
    folder = 'C:\\Users\\Kiran\\ownCloud\\PhD\\sim_results\\drivface';
elseif(ismac)
    folder = '/Users/Kiran/ownCloud/PhD/sim_results/drivface';
else
    folder = '/home/kiran/ownCloud/PhD/sim_results/drivface';
end

knn_1 = 1;
knn_6 = 6;
knn_20 = 20;
msi = 0.015625; alpha = 0.2; 
autoDetectHybrid = 0; isHybrid = 1; continuousRvIndicator = 0;

functionHandlesCell = {@taukl_cc_mi_mex_interface;
                       @tau_mi_interface;
                       @cim;
                       @KraskovMI_cc_mex;
                       @KraskovMI_cc_mex;
                       @KraskovMI_cc_mex;
                       @vmeMI_interface;
                       @apMI_interface;};

functionArgsCell    = {{0,1,0};
                       {};
                       {msi,alpha,autoDetectHybrid,isHybrid,continuousRvIndicator};
                       {knn_1};
                       {knn_6};
                       {knn_20};
                       {};
                       {};};
fNames = {'taukl','tau','cim','knn_1','knn_6','knn_20','vme','ap'};

load(fullfile(folder,'DrivFace.mat'));

X = drivFaceD.data;
y = drivFaceD.nlab;

numFeaturesToSelect = 50;

for ii=1:length(fNames)
    dispstat(sprintf('\t> [FS] Processing %s',fNames{ii}),'keepthis', 'timestamp');
    fs_outputFname = strcat('drivface_fs_',fNames{ii},'.mat');
    fOut = fullfile(folder,fs_outputFname);
    if(~exist(fOut,'file'))
        tic;
        featureVec = mrmr_mid(X, y, numFeaturesToSelect, functionHandlesCell{ii}, functionArgsCell{ii});
        elapsedTime = toc;
        save(fOut,'featureVec','elapsedTime');
    end
end