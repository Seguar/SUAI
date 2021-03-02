clear all
close all
clc
signals = dir('*lora1*.mat');

for k = 1 : numel(signals)
    open(signals(k).name);
    % open lora.mat
    signal = ans.loraData;
    % lora = ans.lora;  
    % clear ans
    % 
    % fft_lora = fft(lora);
%     buf = zeros(1, numel(signal)*2);
%     signal = [buf signal buf];
%     signal = [signal signal signal];
%     return
%     signal = ifft(test);
    % return
    filename = sprintf('lora%d.bin', k);
    fileID = fopen(filename, 'w');
        for i=1:numel(signal)
            if 0 == mod(i, 1e6)
                 sprintf('%d / %d',i ,numel(signal))
            end
        fwrite( fileID, real(signal(i)), 'int8');
        fwrite( fileID, imag(signal(i)), 'int8');
        end
    fclose( fileID);
end