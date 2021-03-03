function agt_download_wave(wave, sampclk, RF, Power, CarrierNoise, ipAddr)
%AGT_DOWNLOAD_WAVE - Download complex wave file to signal generator and playback
% For Agilent ESG E4438C
% 
% Waveform Data Requirements:
% 	Signed 2's complement (32767 = positive full DAC scale output; 0 = 0 volts; ?32768 = negative full DAC scale output)
% 	2-byte integer values
% 	Minimum of 60 samples per waveform (60 I and 60 Q data points)
% 	Interleaved I and Q data (alternating I and Q data points, with the Q data following the I data)
% 	Big endian byte order ( MSB store in lower address and send first )
% 	The same name for the marker, header, and I/Q file 
%	To help minimize signal imperfections, use an even number of samples 
% 
% Volatile (WFM1) Memory Available for Waveform Samples / Memory Size:
% 	Option		Available Samples	Memory Size
% 	--------------------------------------------
% 	001/601		8,377,088			40 MB
% 	002			33,509,120			160 MB
% 	602			67,018,496			320 MB
% 
% 1 sample contains 5 bytes:
%	2(I Data) + 2(Q Data) + 1(Marker Data)  = 5(Waveform Sample)
% 
% Inputs:
%    wave - wave complex samples (5 bytes per sample)
%    sampclk - define the ARB sample clock for playback (samples/s)
%    RF - carrier frequency (Hz)
%    Power - carrier power (dBm)
%    CarrierNoise - C/N (dB)
%    ipAddr - remote ip address (remote port number fix to 5025)
%
% Example:
%		agt_download_wave(rand(100,1)+1i*rand(100,1), 2e3, 1e6, 0, inf, 'localhost')
%
% Other m-files required: 
%     'binblockwrite_.m'
%     'busy_query.m'
%     'error_query.m'
%     'getInstrInfo.m'
%     'send_scpi.m'
%     'error_query.m'
%     'wave2int16.m'
%     'num2str_.m'
% Subfunctions: none
% MAT-files required: none
%
% See also: agt_download_bit.m
% Author: Wang Lei
% Organization: Nanjing University of Aeronautics and Astronautics (NUAA), China
% Email: wanglei_1982@nuaa.edu.cn
% Created: 6-Jan-2011; Last revision: 6-Jan-2011
% ********** Deal Inputs ************************************
if nargin<2 || isempty(sampclk)
    sampclk = 100e3;	% 100kHz
end
if nargin<3 || isempty(RF)
    RF = 10e6;	% 10MHz
end
if nargin<4 || isempty(Power)
    Power = 0;	% 0dBm
end

CarrierNoise = inf;%My

if nargin<5 || isempty(CarrierNoise)
    CarrierNoise = inf;	% C/N (dB)
end
if nargin<6 || isempty(ipAddr)
    ipAddr = 'localhost';	% 66-126  'localhost'
end
% Check min and max number of samples to download
if numel(wave) < 60
	disp('Number of samples should be greater or equal to 60!');
	return;
end
maxSampleLength = 8377088;						% for option 601
if numel(wave) > maxSampleLength					% one samples occupy five bytes
	disp(['Number of samples should not be greater than to ' num2str(maxSampleLength) ' !']);
	return;
end
% ***** Set and Open TCP/IP Object *************************
% set tcp/ip parameters
io = tcpip(ipAddr, 5025, ...
	'InputBufferSize', 100e3, ...	% 100 kBytes
	'OutputBufferSize', 10e6, ...	% 10 MBytes
	'ByteOrder','bigEndian', ...
	'Timeout', 10.0);
% connect to remote host
try
	fopen(io);
catch
	disp(['Cannot Connect to Reomote Host "' ipAddr '" !']);
	fclose(io); delete(io); clear io;
	return;
end
% clear remote host status
fprintf(io,'*cls');
% **** Get Instrument Infomation **************************** 
[InfoStruct,stringIDN] = getInstrInfo(io);
% ****** Just for Verify the Connection ********************* 
if ~nargin
    disp(stringIDN);
    fclose(io); delete(io); clear io;
    return;
end
% ****** Turn Off ARB, Mod, RF ******************************
send_scpi(io,':SOURce:RADio:ARB:STATe OFF');	% disable the arbitrary waveform generator
send_scpi(io,':OUTPut:MODulation:STATe OFF');	% disable the modulation
send_scpi(io, 'OUTPut:STATe OFF');				% disable the RF output
% ******* Download Waveform File ********************************
% complex -> int16
wave_int16 = wave2int16(wave);				% numel(wave_int16) = 2*numel(wave)
% write the waveform data
ArbFileName = '"WFM1:my_wave_file"';			% pathname:filename
status = binblockwrite_(io, wave_int16, 'int16', [':MEMory:DATA ' ArbFileName ', ']);
if status
    disp(['Succeed -- Download Wave File of ' num2str_(size(wave_int16,2)/2) 'Samples to ' InfoStruct.Instrument '.']);
else
	disp('Failed -- Download Wave File not completed.');
end
% ******** Set Baseband Parameters ***********
% select the waveform file for IQ signal
send_scpi(io,[':SOURce:RAD:ARB:WAVeform ' ArbFileName ]);
% Set the sample rate
send_scpi(io, [':SOURce:RADio:ARB:SCLock:RATE ' num2str(sampclk)]);
% Set the filter for I/Q signal
send_scpi(io, ':SOURce:RADio:ARB:IQ:MODulation:FILTer 40e6');     % 2.1e6|40e6|THRough
% ********* Set Noise Parameters*************************
if ~isinf(CarrierNoise)
    % sets the noise bandwidth
    % 1 = 0.8 times the sample rate; 2 = 1.6 times the sample rate, with a maximum bandwidth of 80 MHz.
    send_scpi(io, [':SOURce:RADio:ARB:NOISe:BFACtor 1']);
    % This command selects the carrier bandwidth over which the additive white gaussian noise (AWGN) is
    % applied. The noise Power will be integrated over the selected bandwidth for the purposes of
    % calculating carrier to noise ratio (C/N). The carrier bandwidth is limited to the ARB sample rate, but
    % cannot exceed 80 MHz.
    send_scpi(io, [':SOURce:RADio:ARB:NOISe:CBWidth 1Hz']);
    % This command sets the carrier to noise ratio (C/N) in dB. The carrier Power is defined as the total
    % modulated signal Power without noise Power added. The noise Power is applied over the specified
    % bandwidth of the carrier signal.
    send_scpi(io, [':SOURce:RADio:ARB:NOISe:CN ' num2str(CarrierNoise) 'dB']);
    % This command enables or disables adding real-time additive white gaussian noise (AWGN) to the
    % carrier modulated by the waveform being played by the dual ARB waveform player. The noise
    % bandwidth will be at least 0.8 times the sample rate, or 1.6 times the sample rate depending on the
    % bandwidth factor. For information on the bandwidth factor
    send_scpi(io, ':SOURce:RADio:ARB:NOISe:STATe ON');
else
    send_scpi(io, ':SOURce:RADio:ARB:NOISe:STATe OFF');
end
% ******** Set RF Parameters ***********
send_scpi(io, ['SOURce:FREQuency ' num2str(RF)]);			% set RF frequency
send_scpi(io, ['POWer:LEVel:AMPLitude ' num2str(Power)]);	% set RF amplitude
% ****** Turn on ARB, Mod, RF ******************************
send_scpi(io,':SOURce:RADio:ARB:STATe ON');	% enable the arbitrary waveform generator
send_scpi(io,':OUTPut:MODulation:STATe ON');	% enable the modulation
send_scpi(io, 'OUTPut:STATe ON');				% enable the RF output
% ****** Close the object ******************************
fclose(io); delete(io); clear io;
function status = binblockwrite_(io, A, precision, header)
%BINBLOCKWRITE_ - Write data file to instrument.
% 
% Equal to:
%	binblockwrite(io,A,precision,header); fprintf(io,'\n');
% 
% Syntax:
%	status = binblockwrite_(io, A, precision, header)
% 
% Inputs:
%	io - tcpip object
%	A - data
%	precision - data type: 'uint8' 'uint16'
%	header - head characters
% 
% Outputs:
%	status - true/false
% 
% Examples:
% 
% Other m-files required:
%	busy_query.m
%	error_query.m
% 
% See also: binblockwrite
% Author: Wang Lei
% Organization: Nanjing University of Aeronautics and Astronautics (NUAA), China
% Email: wanglei_1982@nuaa.edu.cn
% Last revision: 06-Jan-2011
% maximum number of bytes to write in one shot
maxBytesSize = 1e6;					% 1M Bytes
BytesPerEle = sizeof(precision);	% bytes per data elements
% calulate N and D
D = numel(A)*BytesPerEle;			% bytes of data
strD = num2str(D);
strN = num2str(length(strD));
filesizeString = ['#' strN strD];
% % Available Bytes of Output Buffer
% BytesAvailableOutput = io.OutputBufferSize - io.BytesToOutput;	
% % Bytes Ready to Write
% ByteToWrite = length(header) + length(filesizeString) + D + 1;	
% if BytesAvailableOutput<ByteToWrite
% 	status = false;
% 	warning('BytesAvailableOutput(%d bytes) < ByteToWrite(%d bytes)', BytesAvailableOutput, ByteToWrite);
% 	return;
% end
% Write out the Header character
fwrite(io,uint8(header),'uint8');
% Write out #<N><D> character
fwrite(io,uint8(filesizeString),'uint8');
% Write out the Data
maxElements = ceil(maxBytesSize/BytesPerEle);			% maximum number of elements to write in one shot
ElementsToWrite = numel(A);								% total number of elements to write
Data = cast(A,precision);								% convert data type
% Break data into blocks to avoid output buffer overflow
while ElementsToWrite > 0
	nElements = min(ElementsToWrite, maxElements);				
	idx = (numel(A)-ElementsToWrite) + (1:nElements);	% index of this block in all data
	fwrite(io, Data(idx), precision);					% write to instrument
	ElementsToWrite = ElementsToWrite - nElements;		% updata elements to process
end
% Write out the ASCII LF character
fwrite(io,uint8(10),'uint8');
% Wait for instrument to complete download
correctCommand = error_query(io);
completedCommand = busy_query(io);
if (correctCommand&&completedCommand)
	status = true;
else
	status = false;
end
function nbytes = sizeof(precision)
% return the number of bytes of a builtin data type.
error(nargchk(1, 1, nargin, 'struct'));
try
    z = zeros(1, precision); %#ok, we use 'z' by name later.
catch
    error('Unsupported class for finding size');
end
w = whos('z');
nbytes = w.bytes;
function status = busy_query(io)
%BUSY_QUERY - query instrument whether the instrument is busy 
% 
% Syntax:
%	status = busy_query(io)
% 
% Inputs:
%	io - tcpip object
% 
% Outputs:
%    status - true if all pending operations have finished
%			  false if otherwise
% 
% Examples:
% 
% Other m-files required:
%	none
% 
% See also: error_query
% Author: Wang Lei
% Organization: Nanjing University of Aeronautics and Astronautics (NUAA), China
% Email: wanglei_1982@nuaa.edu.cn
% Last revision: 06-Jan-2011
statusString = query(io,'*OPC?');
status = strcmp( statusString, ['1' char(10)] );
function status = error_query(io)
%ERROR_QUERY - query instrument whether error exists
% 
% Syntax:
%	status = error_query(io)
% 
% Inputs:
%	io - tcpip object
% 
% Outputs:
%    status - true if no error
%			  false if error detected
% 
% Examples:
% 
% Other m-files required:
%	none
% 
% See also: busy_query
% Author: Wang Lei
% Organization: Nanjing University of Aeronautics and Astronautics (NUAA), China
% Email: wanglei_1982@nuaa.edu.cn
% Last revision: 06-Jan-2011
statusString = query(io,':SYSTem:ERRor?');
statusCell = textscan(statusString, '%s', 'delimiter', ',');
error_number = str2double(statusCell{1}{1});
error_description = statusCell{1}{2};
if error_number == 0
	status = true; % no error
else
	status = false;
	warning(statusString);
end
% +0,"No error" for Agilent	
% 0, 'no error' for RS
function [InfoStruct,idnString] = getInstrInfo(io)
%GETINSTRINFO - get instrument information
% 
% Syntax:
%	[InfoStruct,idnString] = getInstrInfo(io)
% 
% Inputs:
%	io - tcpip object
% 
% Outputs:
%	InfoStruct - information struct
%	idnString - result string of *idn?
% 
% Examples:
% 
% Other m-files required:
%	none
% 
% See also:   
% Author: Wang Lei
% Organization: Nanjing University of Aeronautics and Astronautics (NUAA), China
% Email: wanglei_1982@nuaa.edu.cn
% Last revision: 06-Jan-2011
idnString = query(io,'*idn?');
idnCell = textscan(idnString, '%s', 'delimiter', ',');
idnCell = idnCell{1};
if length(idnCell)<4
	warning('IDN Command error.');
	InfoStruct.Company = [];		
	InfoStruct.Instrument = [];		
	InfoStruct.SerialNumber = [];
	InfoStruct.Firmware = [];		
else
	InfoStruct.Company = idnCell{1};		% company name 'Agilent' 'Rohde&Schwarz'
	InfoStruct.Instrument = idnCell{2};		% model number
	InfoStruct.SerialNumber = idnCell{3};	% serial number
	InfoStruct.Firmware = idnCell{4};		% firmware revision
end
function str = num2str_(x)
% 
% if x < 1e-21
% 	str = [num2str(x*1e24) ' y'];	% yocto
% elseif x < 1e-18
% 	str = [num2str(x*1e21) ' z'];	% zepto
% elseif x < 1e-15
% 	str = [num2str(x*1e18) ' a'];	% atto °?
% elseif x < 1e-12
% 	str = [num2str(x*1e15) ' f'];	% femto ·?
% elseif x < 1e-9
% 	str = [num2str(x*1e12) ' p'];	% pico ?¤
if x < 1e-6
	str = [num2str(x*1e9) ' n'];	% nano ??
elseif x < 1e-3
	str = [num2str(x*1e6) ' u'];	% micro ??
elseif x < 1e0
	str = [num2str(x*1e3) ' m'];	% milli ??	
elseif x < 1e3
	str = [num2str(x*1e-0) ' '];		% -
elseif x < 1e6
	str = [num2str(x*1e-3) ' k'];	% Kilo ?§
elseif x < 1e9
	str = [num2str(x*1e-6) ' M'];	% Mega ??
elseif x < 1e12
	str = [num2str(x*1e-9) ' G'];	% Giga
else % x < 1e15
	str = [num2str(x*1e-12) ' T'];	% Tera
% elseif x < 1e18
% 	str = [num2str(x*1e-15) ' P'];	% Peta
% elseif x < 1e21
% 	str = [num2str(x*1e-18) ' E'];	% Exa
% elseif x < 1e24
% 	str = [num2str(x*1e-21) ' Z'];	% Zetta
% elseif x < 1e27
% 	str = [num2str(x*1e-24) ' J'];	% Jotta
% else
% 	str = [num2str(x*1e-27) ' B'];	% Bronto
end
function status = send_scpi(io, SCPI)
%SEND_SCPI - send scpi command and then query error
% 
% Syntax:
%	send_scpi(io, SCPI)
% 
% Inputs:
%	io - tcpip object
%	SCPI - scpi command
% 
% Outputs:
%	status - true/false true:no error  false:error
% 
% Examples:
%	send_scpi(io, '*idn?')
% 
% Other m-files required:
%	error_query.m
% 
% See also: 
% Author: Wang Lei
% Organization: Nanjing University of Aeronautics and Astronautics (NUAA), China
% Email: wanglei_1982@nuaa.edu.cn
% Last revision: 06-Jan-2011
% send scpi
fprintf(io,SCPI);
% query last error
status = error_query(io);
function y = wave2int16(x)
%WAVE2INT16 - convert complex wave samples to int16 
% [real(1) imag(1) real(2) imag(2) ... real(n) imag(n)]
% 
% Syntax:
%	y = wave2int16(x)
% 
% Inputs:
%	x - complex wave samples
% 
% Outputs:
%	y - output int16
% 
% Examples:
%	y = wave2int16([1 2 3]+1i*[4 5 6])
% Other m-files required:
%	none
% 
% See also: bit2uint8
% Author: Wang Lei
% Organization: Nanjing University of Aeronautics and Astronautics (NUAA), China
% Email: wanglei_1982@nuaa.edu.cn
% Last revision: 06-Jan-2011
% Seperate out the real and imaginary data in the IQ Waveform
x = x(:)';	%
x = [real(x);imag(x)];
x = x(:)';
% Scale the xform
% ARB binary range is 2's Compliment -32768 to + 32767
scale = (2^15-1)/max(abs(x));
x = round(x * scale);
y = int16(x);