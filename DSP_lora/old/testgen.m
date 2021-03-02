clear all
close all
clc

load signal1
load signal2

bw = 125e3;
sf = 7;
tsym = (2^sf) / bw;

pre = 8;
tpre = (pre + 4.25) * tsym;

hd = 20 / sf;
pl = 51 / sf;
plcrc = 16 / sf;
% tall = tpre + (hd + pl + plcrc) * tsym;




% Частота сэмплирования
fd = 2e6;
% 1 отсчет по времени
ts = 1/fd;
t1 = (1:numel(signal1))*ts;
% t2 = (1:numel(signal1))*ts;
% return
n = 2; %кол-во наборов сигналов
filename = input('filename: ', 's');
type = 'int8';

% Амплитуда 1 сигнала
a1 = 10;
% Амплитуда 2 сигнала
a2 = 30;

signal1 = signal1.*a1;
signal2 = signal2.*a2;

% signal = (repmat([zeros(1, numel(signal1)*2) signal2 zeros(1, numel(signal1)*2) signal1.*2], 1, n/2)).*10;
% signal = (repmat([zeros(1, numel(signal1)*2) signal2 zeros(1, numel(signal1)*2) signal1.*2], 1, n/2)).*10;
% Генерация массива с сигналом и паузой 120 мс
signal = [zeros(10, numel(signal1)) repmat(signal1,10,1) zeros(10, numel(signal1))];
% Длительность сигнала в отсчетах
dlit_o = numel(signal2); 
% Длительность сигнала в секундах
dlit = numel(signal1)*ts;
to = (1:numel(signal(1,:)))*ts;
for k = 1:10
    % Инкрементирующийся сдвиг
    sdvig = (dlit/10)*k;
%     return
%     signal(k, :) = fft(signal(k, :));
%     fsignal2 = fft(signal2);
%     signal(k, dlit_o + 1 + sdvig/ts : dlit_o + dlit/ts + sdvig/ts) = signal(k, dlit_o + 1 + sdvig/ts : dlit_o + dlit/ts + sdvig/ts) + fsignal2;
    signal(k, dlit_o + 1 + sdvig/ts : dlit_o + dlit/ts + sdvig/ts) = signal(k, dlit_o + 1 + sdvig/ts : dlit_o + dlit/ts + sdvig/ts) + signal2;
%     signal(k, :) = ifft(signal(k, :));
    figure
    plot(to, signal(k, :));
    fn = [filename sprintf('_%d', k)];
    sdrgen([fn '.bin'], signal(k,:).*2, type)
end
return
% % signal = [zeros(1, numel(signal1)*2) signal zeros(1, numel(signal2)*2)];
% sdrgen([filename '.bin'], signal, type)
