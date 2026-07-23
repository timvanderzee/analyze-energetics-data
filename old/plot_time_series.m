clear all; close all; clc

cd('C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\data_29_01_2026\Nexus')

files = {'P1_c50_1.c3d', 'P1_c100_1.c3d', 'P1_c150_1.c3d', 'P1_c200_1.c3d', 'P1_e50_1.c3d', 'P1_e100_1.c3d'};

colors = lines(length(files));

for kk = 1:length(files)
    data = ezc3dRead(files{kk});

    % Check available analog channels
    analogLabels = data.parameters.ANALOG.LABELS.DATA;

    % Read analog data
    analogData = data.data.analogs;  % [samples × channels]

    %%
    signals_of_interest = {'Voltage.2', 'Angle.Angle', 'Angular Velocity.1', 'Torque.Torque'}; 

    for i = 1:length(signals_of_interest)
        for j = 1:length(analogLabels)
            if strcmp(analogLabels{j}, signals_of_interest(i))
                id(i) = j;
            end
        end
    end

    %% figure 1: time series
    fs = 1000;
    dt = 1/fs;
    N = length(analogData);
    t = 0:dt:(N-1)*dt;

    for i = 1:length(id)
        figure(kk)
        subplot(4,1,i)
        plot(t,analogData(:,id(i)))
    end

end
