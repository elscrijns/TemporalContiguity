% Import the data from each session and calculate the summary table stored in Results
%
% Created by Els Crijns
%
% Last edited on 23-08-2016

%% Import data: .csv files created by TC1_extractData.m

Dir = 'E:\Temporal_Contiguity 01_06_2016\DATA TestingPhase1\ABET data\';
filenames = dir([Dir '*.csv']);
filenames.name;

%% for every file a results table is created containing Performance and significance
% The results are saved as \Results\Results_fileName.csv
n = size(filenames,1) %Number of files

for i = 1:n
    fileName = filenames(i).name

    formatSpec = '%f%d%C%C%C%d%s';
    DATA = readtable([Dir fileName],'Delimiter',',','Format',formatSpec, 'ReadVariableNames', false);
    DATA.Properties.VariableNames =  {'Time' 'Trial' 'Condition' 'correctP' 'touchP' 'Response' 'Schedule'};
    DATA.Properties.Description = fileName;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Sometimes an event is exported several times from ABET.
        % To remove these excess rows we check if the time between events is
        % smaller than the ITI, The duplicate rows are deleted
        
    % Check if the correct amount of trials was recorded, and if ITI 
    % duration  between trials is long enough           
        if  size(DATA,1) > 99
             disp('Too many trials have been recorded. Amount of trials:')
             disp(DATA.Trial(end))
             disp('Events that have an ITI of less than 20 sec')
             find(diff(DATA.Time)<20) + 1
        elseif size(DATA,1) < 99
             disp('Not enough trials have been recorded! Amount of trials:')
             disp(DATA.Trial(end))
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Response = DATA(:,{'Trial' 'Condition' , 'Response'});
    Results.Properties.Description = ' ';
    Results.Properties.DimensionNames = {'Condition' 'Variables'};

    % Calculate the sum of Response per 'Condition'
    Results = grpstats(Response, 'Condition', {'sum'}, 'DataVars' , ...
    'Response', 'VarNames', {'Condition','nTrials','nCorrect'});

    % Calculate the performance based on a Binomial distribution
    [Results.Performance,Results.CI] = binofit(Results.nCorrect, Results.nTrials);

    % Significance?
    Results.p_value = myBinomTest( Results.nCorrect, Results.nTrials, 0.5, 'two');
    Results.Significant = Results.p_value <= 0.05; 

    % Add some additional information to the file 
    Results.Name = {fileName; fileName; fileName};
    schedule = cell2mat(DATA.Schedule(1));
    Results.Schedule = {schedule; schedule; schedule};

    % export mean response
    outFile = [Dir  'Results_' fileName];
    writetable(Results,outFile,'WriteRowNames',false, 'Delimiter', ',')
    
    end 

