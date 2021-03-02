clear all
close all
clc

path = pwd;
pathSig = [pwd '\signal\'];

cd(pathSig)
load signal1
load signal2
cd(path)

bw = 125e3;
sf = 7;
tsym = (2^sf) / bw;
n = 4;
pre = 8;
tpre = (pre + 4.25) * tsym;

hd = 20 / sf;
pl = 51 / sf;
plcrc = 16 / sf;
% tall = tpre + (hd + pl + plcrc) * tsym;

times = zeros(n,1);
times(1,:) = 4 * tsym;
% times(2,:) = tpre + (hd / 2) * tsym;
% times(3,:) = tpre + (hd / 2) * tsym + (pl / 2) * tsym;
% times(4,:) = tpre + (hd / 2) * tsym + (pl / 2) * tsym + (plcrc / 2) * tsym;
times(2,:) = 0.0166;
times(3,:) = 0.0266;
times(4,:) = 0.11;
% return
% Частота сэмплирования
fd = 2e6;
% 1 отсчет по времени
ts = 1/fd;
t1 = (1:numel(signal1))*ts;
% t2 = (1:numel(signal1))*ts;
% return
filename = input('filename: ', 's');
g16 = input('Generate in16? 0/1: ', 's');
pathGen = [pwd '\gensig\' filename  '.mat'];
pathTx = [pwd '\rawgen\' filename];
pathTx16 = [pwd '\rawgen16\' filename];

type = 'int8';

% Амплитуда 1 сигнала
a1 = 1;
% Амплитуда 2 сигнала
% a2 = 11.7*6; % P1 < P2 x6 stat_x6
% a2 = 11.7;  % P1 = P2 stat_gen4
a2 = 1; % P1 > P1 stat_gen3

signal1 = signal1.*a1;
signal2 = signal2.*a2;

% Генерация массива с сигналом и паузой 120 мс
signal = [zeros(10, numel(signal1)) repmat(signal1,10,1) zeros(10, numel(signal1))];
% Длительность сигнала в отсчетах
dlit_o = numel(signal2); 
% Длительность сигнала в секундах
dlit = numel(signal1)*ts;
to = (1:numel(signal(1,:)))*ts;
for k = 1:n
    % Инкрементирующийся сдвиг
    sdvig = times(k);
    signal(k, dlit_o + 1 + sdvig/ts : dlit_o + dlit/ts + sdvig/ts) = signal(k, dlit_o + 1 + sdvig/ts : dlit_o + dlit/ts + sdvig/ts) + signal2;
% return
    figure
    plot(to, signal(k, :));
    fn = [pathTx sprintf('_%d', k)];
    sdrgen([fn '.bin'], signal(k,:).*2, type)
end
save(pathGen, 'signal');
if g16 == '1'
    clear signal sdvig
    signal = [zeros(10, numel(signal1)) repmat(signal1,10,1) zeros(10, numel(signal1))];
    type = 'int16';
    k = 1;
    for k = 1:n
        % Инкрементирующийся сдвиг
        sdvig = times(k);
        signal(k, dlit_o + 1 + sdvig/ts : dlit_o + dlit/ts + sdvig/ts) = signal(k, dlit_o + 1 + sdvig/ts : dlit_o + dlit/ts + sdvig/ts) + signal2;
        fn = [pathTx16 sprintf('_%d', k)];
        sdrgen([fn '.bin'], signal(k,:).*2, type)
    end
end
