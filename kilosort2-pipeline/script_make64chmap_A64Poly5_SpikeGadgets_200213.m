%% prep for making 64 channel map 
% directionality:
%   starting in the bottom left corner, going up the column, up the next,
%   etc etc. 
%   start everything at (1,1) 
%   um scale
%
% ALP 9/11/2020

% to use: copy expressions into kilosort 
% NJ 11/16/21 - adapted Abby's channel map for SpikeGadgets system 

fs = 30000; 
numChan = 64; 
connected = ones(numChan, 1);

%% x coords
%   contacts are in squares of 20um sides so distance horizontally in each row
%   is a^2+b^2 = c^2 -> sqrt(20^2+20^2) = sqrt(800)
%   max distance is 3 contacts/row so max distance is sqrt(800)*2
%   knowing evenly spaced distance between each is sqrt(800)*2/4 or
%   sqrt(800)/2

xc = [ ...
    ones(6,1); ...
    sqrt(800)/2+ones(7,1); sqrt(800)/2*2+ones(6,1); ...
    sqrt(800)/2*3+ones(7,1); sqrt(800)/2*4+ones(6,1); ... %end shank 1
    200+ones(6,1); %point to point is 200um, so add 200
    200+sqrt(800)/2+ones(7,1); 200+sqrt(800)/2*2+ones(6,1); ...
    200+sqrt(800)/2*3+ones(7,1); 200+sqrt(800)/2*4+ones(6,1) ... %end shank 2
    ];

%unwrapped for copying
% [ones(6,1); sqrt(800)/2+ones(7,1); sqrt(800)/2*2+ones(6,1); sqrt(800)/2*3+ones(7,1); sqrt(800)/2*4+ones(6,1); 200+ones(6,1); 200+sqrt(800)/2+ones(7,1); 200+sqrt(800)/2*2+ones(6,1); 200+sqrt(800)/2*3+ones(7,1); 200+sqrt(800)/2*4+ones(6,1)]

%% y coords
%   contacts are in 13 rows with length of 170um
%   so each row is 170/12 um apart from each other

yc = [ ...
    1+(170/12):170/12*2:171-(170/12) 1:170/12*2:170+1 ...
    1+(170/12):170/12*2:171-(170/12) 1:170/12*2:170+1 ...
    1+(170/12):170/12*2:171-(170/12) ... %end shank 1
    1+(170/12):170/12*2:171-(170/12) 1:170/12*2:170+1 ...
    1+(170/12):170/12*2:171-(170/12) 1:170/12*2:170+1 ...
    1+(170/12):170/12*2:171-(170/12) ... % end shank 2
    ]';

%unwrapped for copying
%[1+(170/12):170/12*2:171-(170/12) 1:170/12*2:170+1 1+(170/12):170/12*2:171-(170/12) 1:170/12*2:170+1 1+(170/12):170/12*2:171-(170/12) 1+(170/12):170/12*2:171-(170/12) 1:170/12*2:170+1 1+(170/12):170/12*2:171-(170/12) 1:170/12*2:170+1 1+(170/12):170/12*2:171-(170/12)]


%% k coords
%currently unused by kilosort2, per the issues section it seems that if the
%channels are sufficiently far apart it wont use them together, read the
%issues section for more details

kc = [1*ones(32,1); 2*ones(32,1)] ;

%% channel map
%from my intan channel mapping, following the same order I made the
%coordinates in, starting from bottom left of shank 1, working up and then
%up the next column. start at bottom left of shank 2 as well

chmapShank1 = [ ...
    8 12 13 16 17 18 ...
    10 21 14 23 19 7 20 ...
    5 4 22 1 3 6 ...
    28 30 24 0 26 2 31 ...
    15 9 11 29 27 25 ...
    ]; %end shank 1

chmapShank2 = [ ...
    48 54 52 34 36 38 ...
    35 33 39 63 37 61 32 ...
    59 58 62 41 57 60 ...
    53 42 49 40 44 56 43 ...
    55 51 50 47 46 45 ...
    ]; %end shank 2

chanMap0 = [chmapShank1'; chmapShank2'];
chanMap1 = chanMap0+1; %1 based


%% plot to check
% looks good NJ 11/16/21 - shows hwChan numbers (0-based) per probe location

scatter(xc,yc)
ylim([-10 180])
xlim([-50 300])

hold on; 
text(xc,yc,num2str(chanMap0))

%% rearrange chanMap (hwChan; 0-based) in the order of nTrodeID (1-64)
temp = [xc, yc, kc, chanMap0]; 
temp2 = nan(size(temp)); 
chanMapspreadsheet = xlsread('\\ad.gatech.edu\bme\labs\singer\Rig\Probes\SpikeGadgets_A2x32Poly5_Mapping_200213.xlsx');
nTrodeID = chanMapspreadsheet(:,end-1); %goes from 1-64
hwChan = chanMapspreadsheet(:,end); %associated hwChan number ordered based on nTrode 1-64 
for nt = 1:length(nTrodeID)
    idx = find(chanMap0 == hwChan(nt)); 
    temp2(nt,:) = temp(idx, :); 
end
xcoords = temp2(:,1); 
ycoords = temp2(:,2); 
kcoords = temp2(:,3); 
chanMap0ind = temp2(:,4); 
chanMap = chanMap0ind + 1; 


%% save the map 
savedir = '\\ad.gatech.edu\bme\labs\singer\Nuri\Code\kilosort2-pipeline\kilosort2-pipeline';
save(fullfile(savedir, 'A64Poly5_SpikeGadgetsChanMap_200213.mat'), 'chanMap','chanMap0ind','fs','kcoords','xcoords','ycoords','connected')
