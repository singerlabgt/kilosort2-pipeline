%% prep for making 64 channel map 
% directionality:
%   starting in the bottom left corner, going up the column, up the next,
%   etc etc. 
%   start everything at (1,1) 
%   um scale
%
% ALP 9/11/2020

% to use: copy expressions into kilosort 


%% x coords
%   contacts are in squares of 20um sides so distance horizontally in each row
%   is a^2+b^2 = c^2 -> sqrt(20^2+20^2) = sqrt(800)
%   max distance is 3 contacts/row so max distance is sqrt(800)*2
%   knowing evenly spaced distance between each is sqrt(800)*2/4 or
%   sqrt(800)/2

x = [ ...
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

y = [ ...
    1+(170/12):170/12*2:171-(170/12) 1:170/12*2:170+1 ...
    1+(170/12):170/12*2:171-(170/12) 1:170/12*2:170+1 ...
    1+(170/12):170/12*2:171-(170/12) ... %end shank 1
    1+(170/12):170/12*2:171-(170/12) 1:170/12*2:170+1 ...
    1+(170/12):170/12*2:171-(170/12) 1:170/12*2:170+1 ...
    1+(170/12):170/12*2:171-(170/12) ... % end shank 2
    ];

%unwrapped for copying
%[1+(170/12):170/12*2:171-(170/12) 1:170/12*2:170+1 1+(170/12):170/12*2:171-(170/12) 1:170/12*2:170+1 1+(170/12):170/12*2:171-(170/12) 1+(170/12):170/12*2:171-(170/12) 1:170/12*2:170+1 1+(170/12):170/12*2:171-(170/12) 1:170/12*2:170+1 1+(170/12):170/12*2:171-(170/12)]

%% plot to check
% looks good ALP 9/11/2020

plot(x,y, '*')
ylim([-10 180])
xlim([-50 300])

%% k coords
%currently unused by kilosort2, per the issues section it seems that if the
%channels are sufficiently far apart it wont use them together, read the
%issues section for more details

kcoords = [1*ones(32,1); 2*ones(32,1)] ;

%% channel map
%from my intan channel mapping, following the same order I made the
%coordinates in, starting from bottom left of shank 1, working up and then
%up the next column. start at bottom left of shank 2 as well

chmapShank1 = [ ...
    24 28 29 0 1 2 ...
    26 5 30 7 3 23 4 ...
    21 20 6 17 19 22 ...
    12 14 8 16 10 18 15 ...
    31 25 27 13 11 9 ...
    ]; %end shank 1

chmapShank2 = [ ...
    0 6 4 18 20 22 ...
    19 17 23 15 21 13 16 ...
    11 10 14 25 9 12 ...
    5 26 1 24 28 8 27 ...
    7 3 2 31 30 29 ...
    ]; %end shank 2

chmap = [chmapShank1 chmapShank2+32];
chmap = chmap+1; %1 based

%evaluated the above and copied the result:
chmapfinal = [25,29,30,1,2,3,27,6,31,8,4,24,5,22,21,7,18,20,23,13,15,9,17,11,19,16,32,26,28,14,12,10,33,39,37,51,53,55,52,50,56,48,54,46,49,44,43,47,58,42,45,38,59,34,57,61,41,60,40,36,35,64,63,62];
    