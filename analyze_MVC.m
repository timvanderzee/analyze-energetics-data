clear all; close all; clc
datafolder = 'C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset';
fs = 1000;
dt = 1/fs;

Ps = 15;

muscle_names = {'VL_L', 'VM_L', 'RF_L', 'VL_R', 'VM_R', 'RF_R', 'BF', 'SM', 'GL', 'GM', 'TA', 'VL_L2'};

enums = repmat([4 10 8 6 12 7 5 9 13 11 14 4], 20, 1);

names(1).fname = 'MVC_QUAD_L';
names(1).chns = 1:3;

names(2).fname = 'MVC_QUAD_R';
names(2).chns = 4:6;

names(3).fname = 'MVC_HAMS';
names(3).chns = 7:8;

names(4).fname = 'MVC_ANKLE';
names(4).chns = 9:11;

% when using blue box
enums(11,:) = [4 10 16 12 11 7 15 9 13 1 14 3];
enums(12,:) = [4 10 16 12 11 7 3 9 1 1 14 4];
enums(13,:) = [4 10 16 12 11 7 3 9 1 1 14 4];
enums(14,:) = [4 10 16 12 11 7 3 9 1 1 14 4];
enums(15,:) = [4 10 16 12 11 7 3 9 1 1 14 4];

m = 0;
MVC = nan(Ps,3,4);

for k = 1:4
    
for P = 1:Ps
    

    filename = [datafolder, '\P', num2str(P), '\cybex\p', num2str(P), '_', names(k).fname, '.c3d'];

    if exist(filename, 'file')
        data = ezc3dRead(filename);

        % Check available analog channels
        analogLabels = data.parameters.ANALOG.LABELS.DATA;

        % Read analog data
        analogData = data.data.analogs;  % [samples × channels]

        % filter
        [b1,a1] = butter(1, 20/(.5*fs), 'high');
        [b2,a2] = butter(1, 5/(.5*fs), 'low');

        EMG = analogData(:,enums(P,names(k).chns));
        N = length(analogData);
        t = 0:dt:(N-1)*dt;
        
        EMGf = nan(size(EMG));
        EMGff = nan(size(EMG));
        EMGe = nan(size(EMG));
        
        for j = 1:size(EMG,2)
            EMGf(:,j) = filtfilt(b1,a1, EMG(:,j));
%             EMGff = filtfilt(b2,a2,abs(EMGf(:,j)));
            EMGff = movmean(abs(EMGf(:,j)),500);
            EMGb = mean(EMGff(t < 1));
            EMGe(:,j) = EMGff - EMGb;
        end

        if k == 1 && P == 3
            EMGe(t>60,1) = nan;
        end
        
        figure(k)
        nexttile
        
        for j = 1:size(EMG,2)
            plot(t,EMGf(:,j)+j); hold on
            plot(t,EMGe(:,j) + j, 'k-', 'linewidth', 2)
        end
        
        title(num2str(P))
        xlim([0 min([max(t) 100])])
        box off
        
        for j = 1:size(EMG,2)
            MVC(P,j,k) = max(EMGe(:,j));
        end
    else
        disp(['Does not exist: ', filename])
    end
end
end

%% bad channels
% QUAD_L: all good
% QUAD_R p2 VL: no signal (white 4)
% HAMS p10 BF: no signal (white 5)
% ANKLE
%   - p5 GL: no signal (white 13)
%   - p6 GL: no signal (white 13)

MVCs = [MVC(:,1:3,1) MVC(:,1:3,2) MVC(:,1:2,3) MVC(:,1:3,4)];

%% remove MVCs
MVCs(2,4) = nan;
MVCs(10,7) = nan;
MVCs(5,9) = nan;
MVCs(6,9) = nan;

%% questionable channels
% QUAD_R p11 VL: too much signal (blue 4)
% HAMS p11
%   - BF: a not spiky (blue 15)
%   - SM: little signal (blue 9)
% ANKLE
%   - p1 GL: very noisy (white 13)
%   - p2 GM: very noisy (white 11)
%   - p4 TA: very noisy (white 14)
%   - p5 GM: very noisy (white 11)
%   - p6 TA: very noisy (white 14)

%% save
cd('C:\Users\u0167448\Documents\GitHub\analyze-energetics-data')
save('MVC.mat', 'MVCs')