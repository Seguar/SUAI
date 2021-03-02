filename = input('filename: ', 's');
pathRaw = [pwd '\raw\' filename '.bin '];


cmd = ([pwd '\hackrf\hackrf_transfer.exe -r' pathRaw '-f 868e6 -l 32 -g 32 -s 2e6']);
system(cmd)