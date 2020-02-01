function [recData, timestamps] = importChannels(filename,NumChannels, channels,samplingRate,headerSize, configExists)  


%[recData, timestamps] = importChannels(filename,NumChannels, channels,samplingRate,headerSize, configExists) )  

%Imports channel data in matlab from the raw data file
%
%INPUTS
%filename-- a string containing the name of the .dat file (raw file from SD card)
%NumChannels-- the number of channels in the recording (i.e., 32,64,96...)
%channels-- the channels you want to extract (extracting all channels at once may overload memory)
%samplingRate-- the sampling rate of the recording, i.e 30000
%headerSize--the size, in int16's, of the header block of the data
%(contains DIO channels and aux analog channels).
%
%OUTPUTS
%timestamps--the system clock when each sample was taken
%recData-- an N by M matrix with N data points and M channels (M is equal to the number of channels in the input)

configsize = 0;
if (nargin < 6)
    configExists = 1;   
end

fid = fopen(filename,'r');

if (configExists)
    junk = fread(fid,100000,'uint8');
    configsize = strfind(junk','</Configuration>')+16;
    frewind(fid);
end


if (nargout > 1)
    junk = fread(fid,configsize,'uint8');
    junk = fread(fid,headerSize,'int16');
    timestamps = (fread(fid,[1,inf],'1*uint32=>double',(2*headerSize)+(NumChannels*2))')/samplingRate;
    %timestamps = double(timestamps)/samplingRate;
    frewind(fid);
end

recData = [];
for i = 1:length(channels) 
    
    junk = fread(fid,configsize,'uint8'); %config
    junk = fread(fid,headerSize,'int16'); %header block
    junk = fread(fid,1,'uint32'); %timestamp
    junk = fread(fid,channels(i)-1,'int16'); %skip ahead to the channel
    channelData = fread(fid,[1,inf],'1*int16=>int16',(2*headerSize)+2+(NumChannels*2))';
    frewind(fid);
       
    channelData = double(channelData)*-1; %reverse the sign to make spike point up
    channelData = channelData * 12780; %convert to uV (for Intan digital chips)
    channelData = channelData / 65536;
    recData = [recData channelData];
       
end

fclose(fid);




