%% 
clear all
close all
clc

% Неусущая частота
fs = 868e6;
% Частота сэмплирования
fd = 2e6;
% 1 отсчет по времени
ts = 1/fd;
bw = 125e3;

% Имя файла
filename = input('filename: ', 's');
dsp = input('dsp 0/1: ', 's');
% tx = input('tx 0/1: ', 's');
% Пути файла
pathRaw = [pwd '\raw\' filename '.bin'];
pathRx = [pwd '\rawget\' filename  '.mat'];
pathTx = [pwd '\rawgen\' filename];
pathSig = [pwd '\signal\signal_' filename];
type = 'int8';

%% Rx
if exist(pathRx, 'file')
    signal = open(pathRx);
    signal = signal.signal; 
else 
    signal = sdrget(pathRaw, type);
    save(pathRx, 'signal');
end
figure()
t = (1:numel(signal))*ts;
plot(t, real(signal));
title('Before DSP')
xlabel('Time (s)') 
ylabel('Amplitude (code unit)')
%% DSP
if dsp == '1'
%     return
    tb1 = 2.456/ts;
    te1 = tb1 + bw + 115000;
    s1 = signal(tb1:te1);
    t1 = (1:numel(s1))*ts;
%     figure()
%     plot(t1, real(s1));
    
%     tb2 = 12.912/ts;
%     te2 = 13.032/ts;
%     s2 = signal(tb2:te2);
%     t2 = (1:numel(s2))*ts;
%     
%     figure()
%     plot(t2, real(s2));   
%     return
    fs1 = fft(s1);
    fs1(1) = 0;
    fs1(25000:end)=0;
    signal1 = ifft(fs1);
    save(pathSig, 'signal1');
    
%     fs2 = fft(s2);
%     fs2(1) = 0;
%     fs2(25000:end)=0;
%     signal2 = ifft(fs2);
%     save('signal2', 'signal2');
    
    figure()
    plot(t1, real(signal1), t1, imag(signal1));    
    title('After DSP')
    xlabel('Time (s)') 
    ylabel('Amplitude (code unit)')
    
%     figure()
%     plot(t2, real(signal2), t2, imag(signal2));  
%     title('After DSP')
%     xlabel('Time (s)') 
%     ylabel('Amplitude (code unit)')
end
return
%% Tx
if tx == '1'
    clearvars -except is1 is2 signal pathTx type
%     signal = (repmat([is1*100 is2*100], 1, 10)).*100;
%     sdrgen([pathTx '__1.bin'], signal, type)
%     signal = is2;
%     sdrgen([pathTx '__2.bin'], signal, type)
end