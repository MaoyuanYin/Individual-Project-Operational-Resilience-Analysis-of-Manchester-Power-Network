clear;
clc;
close all;

%% 1) Define variables

scenarioIdx = 5;
startYearNumber = 2023;
endYearNumber = 2050;
days = 365;
startSeasonName = 'winter';
totalNumDataset = 6;
yearOfInterest = 2050; % year of interest to obtain yearly indices in section 5)


%% 2) Calculate EENS, EDLC and EFLC from raw data

% Construct file name for loading initial data
tempFileName = ['scenario_', num2str(scenarioIdx), '_year', num2str(startYearNumber), '_days', num2str(days), '_', startSeasonName];
load(tempFileName);  % Load the data from the specified file

% Initialize matrices to store EENS, EDLC, and EFLC
EENS = zeros(size(ENS_bus, 1), length(startYearNumber:endYearNumber));  % Expected Energy Not Supplied
EDLC = zeros(size(ENS_bus, 1), length(startYearNumber:endYearNumber));  % Expected Duration of Load Curtailment
EFLC = zeros(size(ENS_bus, 1), length(startYearNumber:endYearNumber));  % Expected Frequency of Load Curtailment

% Loop through each year in the specified range
for i = startYearNumber:endYearNumber

    % Initialize temporary storage for each substation's data across all datasets
    ENSbySubstation = zeros(size(ENS_bus, 1), totalNumDataset);
    DLCbySubstation = zeros(size(ENS_bus, 1), totalNumDataset);
    FLCbySubstation = zeros(size(ENS_bus, 1), totalNumDataset);

    % Loop through each dataset
    for j = 1:totalNumDataset

        % Determine file suffix based on dataset number
        if j == 1
            strTemp = '';
        else
            strTemp = ['_(', num2str(j), ')'];
        end

        % Construct the file name for the current dataset and year
        fileName = ['scenario_', num2str(scenarioIdx), '_year', num2str(i), '_days', num2str(days), '_', startSeasonName, strTemp];
        load(fileName);  % Load the dataset

        % Calculate and store sum of energy not supplied for each substation
        ENSbySubstation(:, j) = sum(table2array(ENS_bus), 2);
        DLCbySubstation(:, j) = DLC;  % Store Duration of Load Curtailment data
        FLCbySubstation(:, j) = FLC;  % Store Frequency of Load Curtailment data

    end
    
    % Compute average of all datasets for the year and store results in matrices
    EENS(:, i-startYearNumber+1) = sum(ENSbySubstation, 2) / totalNumDataset;
    EDLC(:, i-startYearNumber+1) = sum(DLCbySubstation, 2) / totalNumDataset;
    EFLC(:, i-startYearNumber+1) = sum(FLCbySubstation, 2) / totalNumDataset;

end


%% 3) Save the EENS, EDLC, and EFLC matrices to a .mat file

switch scenarioIdx
    case 1
        strTemp_2 = 'BestView';
    case 2
        strTemp_2 = 'FallingShort';
    case 3
        strTemp_2 = 'SystemTransformation';
    case 4
        strTemp_2 = 'ConsumerTransformation';
    case 5
        strTemp_2 = 'LeadingTheWay';
end

outputFileName = ['Results_Indices/', strTemp_2, '_year/indices_scenario_', num2str(scenarioIdx), '_year', ...
    num2str(startYearNumber), '-', num2str(endYearNumber), '_days', num2str(days), '_', startSeasonName, '.mat'];

% Convert indices arrays to tables
EENS_table = array2table(EENS);
EDLC_table = array2table(EDLC);
EFLC_table = array2table(EFLC);

% Assign row and column names
rowNames = ENS_bus.Properties.RowNames;
columnNames = arrayfun(@(x) [num2str(x)], startYearNumber:endYearNumber, 'UniformOutput', false);
EENS_table.Properties.RowNames = rowNames;
EENS_table.Properties.VariableNames = columnNames;
EDLC_table.Properties.RowNames = rowNames;
EDLC_table.Properties.VariableNames = columnNames;
EFLC_table.Properties.RowNames = rowNames;
EFLC_table.Properties.VariableNames = columnNames;

% Save the indices arrays and tables
save(outputFileName, 'EENS', 'EDLC', 'EFLC', 'EENS_table', 'EDLC_table', 'EFLC_table');

%% 4) Save the EENS, EDLC, and EFLC matrices to a .xlsx file in separate sheets

% Define the year range
years = startYearNumber:endYearNumber;
yearNames = arrayfun(@(x) num2str(x), years, 'UniformOutput', false);  % Convert year numbers to string array

% Convert EENS to table and set row and column names
EENS_table = array2table(EENS, 'RowNames', ENS_bus.Properties.RowNames, 'VariableNames', yearNames);

% Convert EDLC to table and set row and column names
EDLC_table = array2table(EDLC, 'RowNames', ENS_bus.Properties.RowNames, 'VariableNames', yearNames);

% Convert EFLC to table and set row and column names
EFLC_table = array2table(EFLC, 'RowNames', ENS_bus.Properties.RowNames, 'VariableNames', yearNames);

% Define output file name
outputFileName = ['Results_Indices/', strTemp_2, '_year/indices_scenario_', num2str(scenarioIdx), '_year', ...
    num2str(startYearNumber), '-', num2str(endYearNumber), '_days', num2str(days), '_', startSeasonName, '.xlsx'];

% Write tables to an Excel file with headings automatically included
writetable(EENS_table, outputFileName, 'Sheet', 'EENS', 'WriteRowNames', true);
writetable(EDLC_table, outputFileName, 'Sheet', 'EDLC', 'WriteRowNames', true);
writetable(EFLC_table, outputFileName, 'Sheet', 'EFLC', 'WriteRowNames', true);


%% 5) Save the yearly EENS, EDLC, and EFLC to a .xlsx file in a single sheet

% Calculate the column index for the year of interest
columnIndex = yearOfInterest - startYearNumber + 1;  

% Create a table for the specified year with EENS, EDLC, EFLC as column names
% Extract the respective column from each table for the specified year
dataForYear = table(EENS_table{:, columnIndex}, EDLC_table{:, columnIndex}, EFLC_table{:, columnIndex}, ...
    'VariableNames', {'EENS', 'EDLC', 'EFLC'}, 'RowNames', EENS_table.Properties.RowNames);

% Write this table to an Excel file
outputFileNameYearly = ['Results_Indices/', strTemp_2, '_year/yearly_indices_', num2str(yearOfInterest), '.xlsx'];
writetable(dataForYear, outputFileNameYearly, 'Sheet', num2str(yearOfInterest), 'WriteRowNames', true);


