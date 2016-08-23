% Import the data from each session and calculate the summary of performance stored in Results
%
% Edited by Els Crijns
%
% Last edited on 23-08-2016


clc;clear all;

%% Import data: .csv files created by CollectAll_extractData.m

Dir = 'E:\Temporal_Contiguity 01_06_2016\Collect_All\';
subDir = 'Rat PD Generalization low 1\';
filenames = dir([Dir subDir '*.csv']);
filenames.name;

% remove some record: problem with testing Generalization: all data from
% 24-25/02/2016 is irrelevant
%% for every file a results table is created containing Performance and significance
% The results are saved as \Results\Results_fileName.csv
n = size(filenames,1) % Number of files

for i = 1:n
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Read in the CSV file into a Table named DATA
    
    fileName = filenames(i).name
    %formatSpec = '%d%.3f%d%d%d%d%f%f%f%d%d%d%d';
    formatSpec = '%f%f%f%f%f%f%f%f%f%f%f';
    DATA = readtable([Dir subDir fileName],'Delimiter',',','Format',formatSpec, 'ReadVariableNames', false);
    DATA.Properties.VariableNames =  {'Trial' 'Condition' 'Response' 'CorrectP' 'Time' ...
    'RT' 'RewardTime' 'ScreenPokes' 'FrontBeam' 'BackBeam' 'RewardPokes'};
    DATA.Properties.Description = fileName;
    
    DATA.TimeDiff = [diff(DATA.Time); nan];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Sometimes one event is exported several times from ABET.
    % To remove these excess rows we check if the time between events is
    % smaller than the ITI, The duplicate rows are deleted
    deleteRow = find(DATA.TimeDiff <20) + 1
    DATA(deleteRow,:) = [];
               
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate the sum of Response per 'Spatial Frequency'
%     for t = 1:size(Response,1)
%         if Response.Condition(t) == 1
%             Response.Condition(t) = SF1;
%         elseif Response.Condition(t) == 2
%             Response.Condition(t) = SF2;
%         else
%             Response.Condition(t) = SF3;
%         end
%     end
       
    Results = grpstats(DATA, {'Condition'} , 'mean' , 'DataVars', ...
    {'Response' , 'RT', 'RewardTime', 'TimeDiff', 'ScreenPokes', 'FrontBeam', 'BackBeam' , 'RewardPokes'});
    
    nRows = size(Results,1);
    Results.Date = repmat(fileName(9:18),nRows,1);
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % export the results table to an CSV file
    
    outFile = [Dir 'Results_' fileName(1:7) '.csv'];
    try    
         T = readtable(outFile);
         C = table2cell(Results);
         Results2 = [T ; C];   
         writetable(Results2, outFile,'WriteRowNames',false, 'Delimiter', ',')
    catch
         writetable(Results, outFile,'WriteRowNames',false, 'Delimiter', ',')
    end
    
    outFile_ref = [Dir 'Results_Ref_' fileName(1:7) '.csv'];
    try
         T = readtable(outFile_ref);
         C = table2cell(Results(1,:));
         Results2 = [T ; C]; 
         writetable(Results2, outFile_ref,'WriteRowNames',false, 'Delimiter', ',')
    catch
         writetable(Results([1:end-1],:), outFile_ref,'WriteRowNames',false, 'Delimiter', ',')
    end
        
    outFile_Con = [Dir 'Results_Con_' fileName(1:7) '.csv'];
    try
         T = readtable(outFile_Con);
         C = table2cell(Results(2,:));
         Results2 = [T ; C]; 
         writetable(Results2, outFile_Con,'WriteRowNames',false, 'Delimiter', ',')
    catch
         writetable(Results([1:end-1],:), outFile_Con,'WriteRowNames',false, 'Delimiter', ',')
    end
  
    outFile_swap = [Dir 'Results_Swap_' fileName(1:7) '.csv'];
    try
         T = readtable(outFile_swap);
         C = table2cell(Results(3,:));
         Results2 = [T ; C];
         writetable(Results2, outFile_swap,'WriteRowNames',false, 'Delimiter', ',')
    catch
        writetable(Results(end,:), outFile_swap,'WriteRowNames',false, 'Delimiter', ',')
    end
    
    fclose('all');
    
    % export the Correction trials table to an CSV file
    
%     outFile2 = [Dir  'Correction_' fileName(1:7) '.csv'];
%     try
%         T = readtable(outFile2);
%         C = table2cell(CorrectionTrials);
%         Results = [T ; C];
%         writetable(Results, outFile_SF3,'WriteRowNames',false, 'Delimiter', ',')
%     catch
%         writetable(CorrectionTrials,outFile2,'WriteRowNames', false , 'Delimiter', ',')
%     end
    
    clear DATA Response Results Correction Trial outfile*
end 

clear all
