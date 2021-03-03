filename = input('filename: ', 's');
pathTx = [pwd '\rawgen\' filename];
for n = 1 : 4
    for k = 1 : 100
        name =[pathTx sprintf('_%d.bin', n)];
        cmd = [pwd '\hackrf\hackrf_transfer.exe -t '  name ' -f 868e6 -x 40 -s 2e6'];
        system(cmd)
        disp(name)
    end
    input('Press any key')
end

