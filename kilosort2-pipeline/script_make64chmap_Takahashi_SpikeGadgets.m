%% prep for making 64 channel map 
% directionality:
%   starting in the bottom left corner, going up the column, up the next,
%   etc etc. 
%   start everything at (1,1) 
%   um scale
%
% ALP 9/11/2020
% SMP 210610 adapted for spikegadgets post-2018 headstages

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
figure; hold on;
plot(x,y, '.')
ylim([-10 180])
xlim([-50 300])

%% k coords
%currently unused by kilosort2, per the issues section it seems that if the
%channels are sufficiently far apart it wont use them together, read the
%issues section for more details

k = [1*ones(32,1); 2*ones(32,1)] ;

%% channel map
%data is sorted by nTrode order
%nTrodes go from top of probe to bottom from left to right on shank 1 then left to right on shank 2
%       1       2               33      34
%   3       4       5       35      36      37
%       6       7               38      39
%           ...                     ...
%       31      32              63      64  
%       left shank              right shank
% 
% meanwhile the ordering of the coordinates above is like this
%       13      26              45
%   6       19      32      38
%       12      25              44
%   5       18      31      37
%       11      24              43
%   4       17      30      36
%       10      23              42
%   3       16      29      35
%        9      22              41
%   2       15      28      34
%        8      21              40
%   1       14      27      33
%        7      20              39
%       left shank              right shank
% 
%spreadsheetfile = 'C:\Users\sprince7\Documents\Kilosort-2.0\SpikeGadgets_128Chan_A2x32Poly5_Mapping_210513.xlsx';
nTrodeOrder = 1:64;
chanMapShank1 = [13,26,6,19,32,12,25,5,18,31,11,24,4,17,30,10,23,3,16,29,9,22,2,15,28,8,21,1,14,27,7,20];
chanMapShank2 = chanMapShank1 + 32;
chanMapFinal = [chanMapShank1,chanMapShank2];

%% get the final outputs to copy to kilosort
xMapped = x(chanMapFinal);
yMapped = y(chanMapFinal);
kMapped = k(chanMapFinal);

%plot to check again
for c = 1:length(nTrodeOrder)
    text(xMapped(c),yMapped(c),num2str(nTrodeOrder(c))) 
end

%% what to copy to kilosort
%xcoords = [15.142135623731 43.4264068711929 1 29.2842712474619 57.5685424949238 15.142135623731 43.4264068711929 1 29.2842712474619 57.5685424949238 15.142135623731 43.4264068711929 1 29.2842712474619 57.5685424949238 15.142135623731 43.4264068711929 1 29.2842712474619 57.5685424949238 15.142135623731 43.4264068711929 1 29.2842712474619 57.5685424949238 15.142135623731 43.4264068711929 1 29.2842712474619 57.5685424949238 15.142135623731 43.4264068711929 215.142135623731 243.426406871193 201 229.284271247462 257.568542494924 215.142135623731 243.426406871193 201 229.284271247462 257.568542494924 215.142135623731 243.426406871193 201 229.284271247462 257.568542494924 215.142135623731 243.426406871193 201 229.284271247462 257.568542494924 215.142135623731 243.426406871193 201 229.284271247462 257.568542494924 215.142135623731 243.426406871193 201 229.284271247462 257.568542494924 215.142135623731 243.426406871193];
%ycoords = [171 171 156.833333333333 156.833333333333 156.833333333333 142.666666666667 142.666666666667 128.5 128.5 128.5 114.333333333333 114.333333333333 100.166666666667 100.166666666667 100.166666666667 86 86 71.8333333333333 71.8333333333333 71.8333333333333 57.6666666666667 57.6666666666667 43.5 43.5 43.5 29.3333333333333 29.3333333333333 15.1666666666667 15.1666666666667 15.1666666666667 1 1 171 171 156.833333333333 156.833333333333 156.833333333333 142.666666666667 142.666666666667 128.5 128.5 128.5 114.333333333333 114.333333333333 100.166666666667 100.166666666667 100.166666666667 86 86 71.8333333333333 71.8333333333333 71.8333333333333 57.6666666666667 57.6666666666667 43.5 43.5 43.5 29.3333333333333 29.3333333333333 15.1666666666667 15.1666666666667 15.1666666666667 1 1];
%kcoords = [1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2]

%% save as a csv file if needed
channelMapT = array2table([xMapped, yMapped', kMapped],'VariableNames',{'X','Y','K'});
writetable(channelMapT, 'C:/Users/sprince7/Desktop/A2x32-Poly5-10mm-20s-200-100-probemap.csv');
