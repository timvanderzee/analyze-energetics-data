for i = 1:size(EMG,2)
    
    figure(10)
    plot(t, EMG(:,i)+i); hold on
end

%%
titles = {'Rest', 'Active'};
close all

for i = 1:2
    Fs = 1000;              % Sampling frequency (Hz)
    T = 1/Fs;               % Sampling period
    
    % Create a sample signal: 50 Hz and 120 Hz
    % x = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t);
    
    if i == 1
        y = EMG(t<50,1) - mean(EMG(t<50,1));
    else
        y = EMG(t>50,1) - mean(EMG(t>50,1));
    end
    
    [b1,a1] = butter(4, [220 260]/(.5*fs), 'stop');
    yf = filtfilt(b1,a1, y);
    
    [b1,a1] = butter(4, [100 140]/(.5*fs), 'stop');
    yf = filtfilt(b1,a1, yf);
    
    L = length(y);           % Length of signal
    tn = (0:L-1)*T;          % Time vector
    
    % Compute the Fast Fourier Transform
    Y = fft(y);
    Yf = fft(yf);

    
    % Compute the two-sided spectrum P2. Then compute the single-sided spectrum P1
    P2 = abs(Y/L);
    P1 = P2(1:floor(L/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);
    
    P2f = abs(Yf/L);
    P1f = P2f(1:floor(L/2)+1);
    P1f(2:end-1) = 2*P1f(2:end-1);
    
    % Define the frequency domain f
    f = Fs*(0:(L/2))/L;
    
    % Plot the Single-Sided Amplitude Spectrum
    figure(20);
    subplot(3,2,i)
    loglog(f,P1); hold on

    % title('Single-Sided Amplitude Spectrum of x(t)')
    xlabel('Frequency (Hz)')
    ylabel('|P1(f)|')
    box off
    axis([1e-1 500 1e-8 1e-2])
    
    title(titles{i})
    
    subplot(3,2,i+2)
    loglog(f,P1f); hold on
    box off
    axis([1e-1 500 1e-8 1e-2])
    
    subplot(3,2,i+4)
    plot(tn,  y, tn, yf+i/10)
    
end