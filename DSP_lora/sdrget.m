function [signal] = sdrget(filename, type)
    % Перевод сырых данных форматом для SDR в комплексные массивы
    % [complex] (string, , int8/int16)
    file = fopen(filename, 'r');
    data = fread(file, Inf, type);
    fclose(file);
    sizeIQ = size(data, 1) / 2;
    signal = zeros(1, sizeIQ);
        for i = 1 : numel(signal)
            if 0 == mod(i, 1000000)
                sprintf('%d / %d',i ,sizeIQ)
            end
            signal(i) = data((i - 1) * 2 + 1) + 1i * data((i - 1) * 2 + 2);
        end
    disp('sdrget done')
end