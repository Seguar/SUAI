function [] = sdrgen(filename, signal, type)
    % Перевод комплексных массивов в сырые данные форматом для SDR     
    % (string, complex, int8/int16)
    fileID = fopen(filename, 'w');
        for i=1:numel(signal)
            % Вывод прогресса
            if 0 == mod(i, 1e6)
                 sprintf('%d / %d',i ,numel(signal))
            end
            % Запись действительной части в файл
            fwrite( fileID, real(signal(i)), type);
            % Запись мнимой части в файл
            fwrite( fileID, imag(signal(i)), type);
        end
    fclose( fileID);
    disp('sdrgen done')
end