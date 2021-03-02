function [] = sdrgen(filename, signal, type)
    % ������� ����������� �������� � ����� ������ �������� ��� SDR     
    % (string, complex, int8/int16)
    fileID = fopen(filename, 'w');
        for i=1:numel(signal)
            % ����� ���������
            if 0 == mod(i, 1e6)
                 sprintf('%d / %d',i ,numel(signal))
            end
            % ������ �������������� ����� � ����
            fwrite( fileID, real(signal(i)), type);
            % ������ ������ ����� � ����
            fwrite( fileID, imag(signal(i)), type);
        end
    fclose( fileID);
    disp('sdrgen done')
end