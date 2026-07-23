close all
ishift = 1300; 

Y = [-Kangle(t<310) Tknee(t<310)];

Y = [Y(ishift:end,1) Y(1:end-ishift+1,2)];
t = t(ishift:end);

[b,a] = butter(1, .1/(.5*fs), 'low');

Y_filt = nan(size(Y));

for i = 1:2
    Y_filt(:,i) = filtfilt(b,a,Y(:,i));
end

clear alocs
for i = 1:2
    
    subplot(2,1,i)
    plot(t(t<310), [Y(:,i) Y_filt(:,i)]); hold on
    
    [apks, alocs(i,:)] = findpeaks(Y_filt(:,i),t(t<310));
    plot(alocs(i,:),apks, 'o')
    
    box off
    axis tight
end

%%

 
figure(2); 
plot(Y_filt(:,1), Y_filt(:,2),'.')
 

% [C,LAGS] = xcorr(Y_filt(:,1)-mean(Y_filt(:,1)),Y_filt(:,2)-mean(Y_filt(:,2)));
% plot(LAGS, C)