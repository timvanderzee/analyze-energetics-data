clear all; close all; clc
datafolder = 'C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\dataset';
fs = 1000;
dt = 1/fs;

muscle_names = {'VL_L', 'VM_L', 'RF_L', 'VL_R', 'VM_R', 'RF_R', 'BF', 'SM', 'GL', 'GM', 'TA', 'VL_L2'};

enums = repmat([4 10 8 6 12 7 5 9 13 11 14 4], 20, 1);

names(1).fname = 'MVC_QUAD_L';
names(1).chns = [1:3 12];

names(2).fname = 'MVC_QUAD_R';
names(2).chns = 4:6;

names(3).fname = 'MVC_HAMS';
names(3).chns = 7:8;

names(4).fname = 'MVC_ANKLE';
names(4).chns = 9:11;

% when using blue box
enums(11,:) = [4 10 16 12 11 7 15 9 13 1 14 3];

for k = 1:4
    
for P = 1:11
    

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
            EMGff = filtfilt(b2,a2,abs(EMGf(:,j)));
            EMGb = mean(EMGff(t < 1));
            EMGe(:,j) = EMGff - EMGb;
        end
        
        figure(k)

        nexttile
        
        for j = 1:size(EMG,2)
            plot(t,EMGf(:,j)+j); hold on
            plot(t,EMGe(:,j) + j, '--')
        end
        
        title(num2str(P))
        xlim([0 min([max(t) 100])])
        box off
    end
end
end
