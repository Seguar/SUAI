filename = input('filename: ', 's');
pathTx = [pwd '\rawgen\' filename];

for k = 1 : Inf
    for n = 1 : 4
        name =[pathTx sprintf('_%d.bin', n)];
        cmd = [pwd '\hackrf\hackrf_transfer.exe -t ' pwd '\' name ' -f 868e6 -x 40 -s 2e6'];
        system(cmd)
        disp(name)

    end
    
end

