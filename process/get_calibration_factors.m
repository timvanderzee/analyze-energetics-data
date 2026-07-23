clear all; close all; clc
addpath(genpath(cd))

cd(['C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\2302\P3\t2'])


%% torque calibration
data = ezc3dRead('calibration_370Nm.c3d');

% Check available analog channels
analogLabels = data.parameters.ANALOG.LABELS.DATA;

% Read analog data
analogData = data.data.analogs;  % [samples × channels]
signals_of_interest = {'Angle.Angle', 'Angular Velocity.1', 'Torque.Torque'}; 

for i = 1:length(signals_of_interest)
    for j = 1:length(analogLabels)
        if strcmp(analogLabels{j}, signals_of_interest(i))
            id(i) = j;
        end
    end
end

% figure 1: time series
fs = 1000;
dt = 1/fs;
N = length(analogData);
t = 0:dt:(N-1)*dt;

for i = 1:length(id)
    figure(1)
    subplot(3,1,i)
    plot(t,analogData(:,id(i)))
end

%% average over intervals
tint = [0 10; 30 40; 65 75; 90 100; 120 140];
color = lines(6);
Tmean = nan(1,size(tint,1));
figure(1)

for i = 1:size(tint,1)
    xline(tint(i,:), '--', 'color', color(i,:))
    
    tid = t > tint(i,1) & t < tint(i,2);
    Tmean(i) = -mean(analogData(tid,id(3)));
    
    yline(Tmean(i), ':', 'color', color(i,:))
    
end

dTmean = Tmean(2:end) - Tmean(1); % change in torque

%% signal versus weights
r = .45; % momentarm
dTweights = cumsum([25.14 25.03 24.99 25.07]) * 0.453592 * 9.81 * r;

p = polyfit(dTmean,dTweights,1);
x = linspace(0, max(dTmean)*1.2,100);

if ishandle(2), close(2); end
figure(2)
plot(dTmean,dTweights,'o'); hold on
plot(x, polyval(p, x),'--')

% conclusion: slope = 993 (suspiciously close to 1000)

%% angle calibration
data = ezc3dRead('calibration_angle_90deg.c3d');
% Check available analog channels
analogLabels = data.parameters.ANALOG.LABELS.DATA;

% Read analog data
analogData = data.data.analogs;  % [samples × channels]

signals_of_interest = {'Angle.Angle', 'Angular Velocity.1', 'Torque.Torque'}; 

for i = 1:length(signals_of_interest)
    for j = 1:length(analogLabels)
        if strcmp(analogLabels{j}, signals_of_interest(i))
            id(i) = j;
        end
    end
end

% figure 1: time series
fs = 1000;
dt = 1/fs;
N = length(analogData);
t = 0:dt:(N-1)*dt;

for i = 1:length(id)
    figure(3)
    subplot(3,1,i)
    plot(t,analogData(:,id(i)))
end

tint = [0 10; 40 50];
color = lines(6);
Amean = nan(1,size(tint,1));
figure(3)

for i = 1:size(tint,1)
    tid = t > tint(i,1) & t < tint(i,2);
    Amean(i) = mean(analogData(tid,id(1)));
    
    subplot(311)    
    xline(tint(i,:), '--', 'color', color(i,:))  
    yline(Amean(i), ':', 'color', color(i,:))
    
end

slope = 180/diff(Amean);

% conclusion: slope =  57.4670 (suspiciously close to 180/pi)