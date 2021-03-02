close all
clear all
clc

% dataBegin = 10e6;
% dataEnd = 30.5e6;

%%
filename = 'raw_2';
file = fopen([filename '.bin'], 'r');
data = fread(file, Inf, 'int8');
fclose(file);
sizeIQ = size(data, 1) / 2;

dataIQ = zeros(1, sizeIQ);
for i = 1 : numel(dataIQ)
    if 0 == mod(i, 1000000)
        sprintf('%d / %d',i ,sizeIQ)
    end
    dataIQ(i) = data((i - 1) * 2 + 1) + 1i * data((i - 1) * 2 + 2);
end
clear data
%% Сохранение
% fdata = fft(dataIQ);
% fdata = fdata(1000:end-1000);
% lora = dataIQ(1:dataEnd);
% save lora lora
%%
% dataIQ = fft(dataIQ);

% dataIQ = dataIQ(1000:end-1001);

% 
% figure
% plot(1:numel(dataIQ), imag(dataIQ),1:numel(dataIQ), real(dataIQ))
% return
shag = 1e5;
loraNum = 1;

konec = round(numel(dataIQ)/shag)*shag;
% for k = 1 : shag : konec
%     dataBegin = k;
%     dataEnd = k + shag - 1;   
%     data = fft(dataIQ(dataBegin:dataEnd));
    data = fft(dataIQ);
    data(1:2) = 0;
%     data(1:2000) = 0;
%     data(10000:end) = 0;
%     if max(real(data)) >= 2000
%         figure
%         plot(1:numel(data), imag(data),1:numel(data), real(data))
%         loraData(loraNum,:) = ifft(data);
        loraData = ifft(data);
        treshold = max(abs(loraData));
        positions = find(abs(loraData) > treshold/3);
        loraData = loraData(positions(1):positions(end));
        signalName = sprintf('lora%d.mat',loraNum );
        save(signalName, 'loraData');
        loraNum = loraNum + 1;

%         signalName
%     end
% end
% dataIQ = dataIQ(dataBegin:dataEnd);
% dataIQ = fft(dataIQ);
% dataIQ = dataIQ(1000:end-1001);
% plot(1:numel(dataIQ), imag(dataIQ),1:numel(dataIQ), real(dataIQ))
return
figure
plot(1:numel(fdata), real(fdata))
