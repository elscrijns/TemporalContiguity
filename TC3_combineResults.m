% Combine all results (summary tables) of each rat into datamatrix per
% measure: nTrials, nCorrect, Performance, Schedule
% Save to an excell file combinedResults.xlsx
%
% Created by Els Crijns
%
% Last edited: 23-08-2016

%% Open all the Results files: each file contains a summary of the performance of one animal
% Condition,nTrials,nCorrect,Performance,CI_1,CI_2,p_value,Significant,Name,Schedule

Dir = 'E:\Temporal_Contiguity 01_06_2016\DATA TestingPhase1\Results per animal\';
filenames = dir([Dir 'Results*.csv']);

n = size(filenames,1)
name = {};
nTrials = [];
nCorrect = [];
Performance = [];
Schedule = {};

%% A summary of all the animals per condition is created and saved to an excel file

for i = 1:n
fileName = filenames(i).name;

formatSpec = '%d%d%d%f%f%f%f%d%s%s';
DATA = readtable([Dir fileName], 'Delimiter',',','Format',formatSpec, 'ReadVariableNames', true);

name(1,i) = {fileName};
nTrials(:,i) = DATA.nTrials;
nCorrect(:,i) = DATA.nCorrect;
Performance(:,i) = DATA.Performance;
Schedule(1,i) = strrep(DATA.Schedule(1), 'Rat PD Generalization ' , '');
end 
Performance(3,:) =  1- Performance(3,:) % Performance for the third stimulus
% was recorded as correct responses towards the swap orientation, and is
% thus reversed with respect to other stimuli

%% Adjust Schedule names

Schedule = strrep(Schedule, 'low 1', 'Low 1');

%% save to an excel file
outFile = [Dir 'combinedResults.xls'];
    xlswrite(outFile, name' , 'nTrials', 'A2' )
    xlswrite(outFile, name' , 'nCorrect', 'A2' )
    xlswrite(outFile, name' , 'Performance', 'A2' )
    xlswrite(outFile, nTrials' , 'nTrials', 'B2' )
    xlswrite(outFile, nCorrect' , 'nCorrect', 'B2' )
    xlswrite(outFile, Performance' , 'Performance', 'B2')
    xlswrite(outFile, Schedule' , 'nTrials', 'E2' )
    xlswrite(outFile, Schedule' , 'nCorrect', 'E2' )
    xlswrite(outFile, Schedule' , 'Performance', 'E2' )

%% summary
sumTrials = sum(nTrials, 2);
sumCorrect = sum(nCorrect, 2);
meanPerf = mean(Performance, 2);
groupBinomTest = myBinomTest(sumCorrect, sumTrials, 0.5, 'two');

% save to file
    xlswrite(outFile, sumTrials', 'nTrials' , 'B1' )
    xlswrite(outFile, sumCorrect', 'nCorrect', 'B1' )
    xlswrite(outFile, meanPerf', 'performance', 'B1' )
    
%%  Use dfittool to create a probability density plot

%createFit(Performance(1,:),Performance(2,:),Performance(3,:))

