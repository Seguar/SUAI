% load('signal1');
load('signal_dva');
% return
n = 10;
IQData = signal(n, :);
% agt_download_wave(IQData(240002:end), 2e6, 868.21e6, 0, 10, '192.168.1.101');
agt_download_wave(IQData, 2e6, 868.21e6, 0, 10, '192.168.1.101');