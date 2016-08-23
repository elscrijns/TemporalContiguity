% Convert data from ABET to a csv file with one variable per column
%
% Created by Christophe Bossens
% Edited by Els Crijns
%
% Last edited on 23-08-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Takes csv data from:
clc;clear all;
filename = 'TC_CollectAll.csv';
outputPath = 'E:\Temporal_Contiguity 01_06_2016\Collect_All\';
filepath = 'E:\Temporal_Contiguity 01_06_2016\Collect_All\';
useExcel = 0;
saveFile = 1;
if ~exist([filepath filename],'file')
    display('Error, could not find filename');
end

warning off MATLAB:MKDIR:DirectoryExists

%% Read data using excel reader or csv reader
if useExcel ~= 0
    [nData, text, alldata] = xlsread([filepath filename]);
    alldata(1,:) = [];
else
    fid = fopen([filepath filename]);
    fgetl(fid);
    rowIndex = 1;
    
    while ~feof(fid)
        nextLine = fgetl(fid);
        items = find(nextLine == '	');
        items = [0 items length(nextLine)+1];
        for i = 1:(length(items)-1)
            if i > 4
                alldata{rowIndex,i} = str2double(nextLine(items(i)+2 : items(i+1)-2));
            else
                alldata{rowIndex,i} = nextLine(items(i)+2 : items(i+1)-2);
            end
        end
        rowIndex = rowIndex + 1;
    end
    fclose(fid);
end

%% Find row with maximal number of events, all other rows are aligned to
% this
maxResponses = max(cell2mat(alldata(1:end,5)));
maxRTs = max(cell2mat(alldata(1:end,6)));
maxCollects = max(cell2mat(alldata(1:end,7)));
maxScreenPokes = max(cell2mat(alldata(1:end,8)));
maxFBeamCrosses = max(cell2mat(alldata(1:end,9)));
maxBBeamCrosses = max(cell2mat(alldata(1:end,10)));
maxRewardPokes = max(cell2mat(alldata(1:end,11)));

excludeSchedules = {'Rat Pairwise Must Touch Training v2' 
                    'Rat Pairwise Must Initiate Training v2'
                    'Rat Pairwise Initial Touch Training v2'
                    'Rat Pairwise Punish Incorrect Training v2'
                    'Rat Pairwise Habituation 1'};
             
for rowIndex = 1:size(alldata,1)
   schedule = alldata{rowIndex,1};
   runtime = alldata{rowIndex,2};
   animalID = cell2mat(alldata(rowIndex,3));
   groupID = cell2mat(alldata(rowIndex,4));
   if (isempty(groupID))
       groupID = '99';
   end
   if (isempty(animalID))
       animalID = '99';
   end
   if (sum(strncmp(schedule,excludeSchedules,length(schedule))) > 0)
       continue
   end
   
   % Get the number of data points
   % The standard shaping protocols contain different parameters so they
   % should not be analysed using this script
   nResponses = cell2mat(alldata(rowIndex,5));
   nRTs = cell2mat(alldata(rowIndex,6));
   nCollects = cell2mat(alldata(rowIndex,7));
   nScreenPokes = cell2mat(alldata(rowIndex,8));
   nFBeamCrosses = cell2mat(alldata(rowIndex,9));
   nBBeamCrosses = cell2mat(alldata(rowIndex,10));
   nRewardPokes = cell2mat(alldata(rowIndex,11));
   
   if (isnan(nScreenPokes))
       nScreenPokes = 0;
   end
   if (isnan(nBBeamCrosses))
       nBBeamCrosses = 0;
   end
   if (isnan(nFBeamCrosses))
       nFBeamCrosses = 0;
   end
   if (isnan(nRewardPokes))
       nRewardPokes = 0;
   end
   
   % Parse the date
   separators = find(runtime == '/');
   day = runtime(1:separators(1)-1);
   month = runtime(separators(1)+1:separators(2)-1);
   year = runtime(separators(2)+1:separators(2)+4);
   if length(month) == 1
       month = ['0' month];
   end
   if length(day) == 1
       day = ['0' day];
   end
   
   % Extract response data
   responseOffset = 12;
   timeStamps = cell2mat(alldata(rowIndex,responseOffset:(responseOffset+nResponses-1)));
   responseEvaluations = cell2mat(alldata(rowIndex,(responseOffset +   maxResponses):(responseOffset +   maxResponses + nResponses - 1)));
   correctPositions = cell2mat(alldata(rowIndex,   (responseOffset + 2*maxResponses):(responseOffset + 2*maxResponses + nResponses - 1)));
   targetIndex = cell2mat(alldata(rowIndex,       (responseOffset + 3*maxResponses):(responseOffset + 3*maxResponses + nResponses - 1)));
   %correctionTrial = cell2mat(alldata(rowIndex,   (responseOffset + 4*maxResponses + 1 ):(responseOffset + 4*maxResponses + nResponses)));
   
   Index = find(diff(timeStamps) < 20) + 1;
   timeStamps(Index)= [];
   responseEvaluations(Index)= [];
   correctPositions(Index)= [];
   targetIndex(Index) = [];
   nResponses = length(timeStamps);
   
   % Extract RT data
   rtOffset = responseOffset + 4*maxResponses;
   reactionTimes = cell2mat(alldata(rowIndex, rtOffset:(rtOffset + nRTs - 1)));
   
  
   % Extract collection time data
   collectOffset = rtOffset + maxRTs;
   collectionTimes = cell2mat(alldata(rowIndex,collectOffset:(collectOffset + nCollects-1)));
   
   % Extract screen poke data
   screenPokeOffset = collectOffset + maxCollects;
   screenPokeTimes = cell2mat(alldata(rowIndex,screenPokeOffset:(screenPokeOffset + nScreenPokes-1)));
   
   % Extract front beam cross data
   fBeamCrossOffset = screenPokeOffset + maxScreenPokes;
   fBeamCrossTimes = cell2mat(alldata(rowIndex,fBeamCrossOffset:(fBeamCrossOffset + nFBeamCrosses-1)));
   
   % Extract back beam cross data
   bBeamCrossOffset = fBeamCrossOffset + maxFBeamCrosses;
   bBeamCrossTimes = cell2mat(alldata(rowIndex,bBeamCrossOffset:(bBeamCrossOffset + nBBeamCrosses-1)));
   
   % Extract reward entry data
   rewardPokeOffset = bBeamCrossOffset + maxBBeamCrosses;
   rewardPokeTimes = cell2mat(alldata(rowIndex,rewardPokeOffset:(rewardPokeOffset + nRewardPokes-1)));
   
   
   % Add reward collection time. We will not be able to collect collection
   % times if the last trial in a session was a correct trial and the
   % animal failed to collect the reward in time
   rewardCollectionTimes = zeros(1,nResponses);
   correctResponseCounter = 1;
   
   for i = 1:length(responseEvaluations)
       if responseEvaluations(i) == 1
           rewardCollectionTimes(i) = collectionTimes(correctResponseCounter);
           correctResponseCounter = correctResponseCounter + 1;
       end
       if correctResponseCounter > nCollects
           break;
       end
   end
   
   if (correctResponseCounter ~= sum(responseEvaluations)) && (correctResponseCounter-1 ~= sum(responseEvaluations))
       display(['Collection time mismatch in file @ ' num2str(rowIndex) ': ' schedule ',' runtime ',' animalID ',' groupID]);
       continue
   end
   
   % measure ISI activity (screen pokes, beam crossings, reward pokes
   isiScreenPokeCount = zeros(1,nResponses);
   isiFBCrossings = zeros(1,nResponses);
   isiBBCrossings = zeros(1,nResponses);
   isiRewardNosePokes = zeros(1, nResponses);
   
   for i = 2:nResponses
       if responseEvaluations(i-1) == 1
           isiStart = timeStamps(i-1) + rewardCollectionTimes(i);
       else
           isiStart = timeStamps(i-1);
       end
       isiEnd = timeStamps(i)-reactionTimes(i);
       
       isiScreenPokeCount(i-1) = length(find(screenPokeTimes > isiStart & screenPokeTimes < isiEnd));
       isiFBCrossings(i-1) = length(find(fBeamCrossTimes > isiStart & fBeamCrossTimes < isiEnd));
       isiBBCrossings(i-1) = length(find(bBeamCrossTimes > isiStart & bBeamCrossTimes < isiEnd));
       isiRewardNosePokes(i-1) = length(find(rewardPokeTimes > isiStart & rewardPokeTimes < isiEnd));
   end
   
   % Check if number of events matches number of reaction times
   if nResponses ~= nRTs
       display(['Reaction time mismatch in file @ ' num2str(rowIndex) ': ' schedule ',' runtime ',' animalID ',' groupID]);
       continue
   end
   
   % Save to file
   if saveFile == 1
       mkdir(outputPath,schedule);
       %mkdir([outputPath schedule],groupID);
       %mkdir([outputPath schedule '\' groupID], animalID);
       fid = fopen([outputPath schedule '\' groupID '_' animalID '_' year '-' month '-' day '.csv'],'a');
       for i = 1:nResponses
           fprintf(fid,[num2str(i) ',' num2str(targetIndex(i)) ',' num2str(responseEvaluations(i)) ',' ...
               num2str(correctPositions(i)) ',' num2str(timeStamps(i)), ',' num2str(reactionTimes(i)) ',' ...
               num2str(rewardCollectionTimes(i)) ',' num2str(isiScreenPokeCount(i)) ',' ...
               num2str(isiFBCrossings(i)) ',' num2str(isiBBCrossings(i)) ',' num2str(isiRewardNosePokes(i)) '\n']);
       end
       fclose(fid);
   end
end