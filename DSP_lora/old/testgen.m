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




% ������� �������������
fd = 2e6;
% 1 ������ �� �������
ts = 1/fd;
t1 = (1:numel(signal1))*ts;
% t2 = (1:numel(signal1))*ts;
% return
n = 2; %���-�� ������� ��������
filename = input('filename: ', 's');
type = 'int8';

% ��������� 1 �������
a1 = 10;
% ��������� 2 �������
a2 = 30;

signal1 = signal1.*a1;
signal2 = signal2.*a2;

% signal = (repmat([zeros(1, numel(signal1)*2) signal2 zeros(1, numel(signal1)*2) signal1.*2], 1, n/2)).*10;
% signal = (repmat([zeros(1, numel(signal1)*2) signal2 zeros(1, numel(signal1)*2) signal1.*2], 1, n/2)).*10;
% ��������� ������� � �������� � ������ 120 ��
signal = [zeros(10, numel(signal1)) repmat(signal1,10,1) zeros(10, numel(signal1))];
% ������������ ������� � ��������
dlit_o = numel(signal2); 
% ������������ ������� � ��������
dlit = numel(signal1)*ts;
to = (1:numel(signal(1,:)))*ts;
for k = 1:10
    % ������������������ �����
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
