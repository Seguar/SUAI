filename = input('filename: ', 's');
pathTx16 = [pwd '\rawgen16\' filename];

for k = 1 : Inf
    for n = 1 : 4
        name = [pathTx16 sprintf('_%d.bin', n)];
        cmd = [pwd '\lime\limesdrTransfer.exe - ' pwd '\' name ' -f 868000000 -x 40 -s 2000000'];
        system(cmd)
        disp(name)

    end
    
end

