cd('C:\Users\u0167448\OneDrive - KU Leuven\10. Energetics\2502')

data = ezc3dRead('vicon_test04.c3d');

%%
% Check available analog channels
analogLabels = data.parameters.ANALOG.LABELS.DATA;

% Read analog data
analogData = data.data.analogs;  % [samples × channels]

%%
figure(1)

for i = 1:2
    subplot(1,2,i)
    plot(squeeze(data.data.points(:,i,:))')
end