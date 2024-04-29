clear;
clc;
close all;

for yearNumber = 2:30

    %% 1) Initialise parameters

    % Filepath:
    fileName = "Database_Manchester_Formatted_Test.xlsx";
    
    % Simulation parameters:
    days = 1; % number of days in the simulation
    resolutionHours = 1; % resolution of simulation (in hours) (should be 0.5, 1, 2...)
    scenarioIdx = 5; % 1 --> BV, 2 --> FS, 3 --> ST, 4 --> CT, 5 --> LTW
    % yearNumber = 17; % 1 --> 2022, 2 --> 2023 ... 30 --> 2051
    startSeason = 4; % demand profiles start from: 1 --> Spring, 2 --> Summer,
                       % 3 --> Fall, 4 --> Winter, 5 --> any index specifed below
    readProfileStartIndex = 1; % this is used only when 'yearVariation' = 5;
    
    % Assets parameters:
    failureRate = 1.08; % failure rate per year
    repairRate = 198; % repair rate per year
    
    % Switch functionalities:
    ifScaleDemand = 0; % if all loads are multiplied by 'demandScaler' value
    demandScaler = 1;
    ifSwitchBranches = 1;
    ifPlotResults = 0;
    ifWriteResults = 1; % if write results into a .mat file in 'Results' folder
    
    tic;
    
    
    %% 2) Initialise MATPOWER case struct (import the network model)
    mpc.version = '2';
    mpc.baseMVA = 100;
    
    % Input bus information
    mpc.bus = readmatrix(fileName,'Sheet','Bus','Range','D5:P54');
    num_bus = size(mpc.bus,1);
    
    % Input branch information
    mpc.branch = readmatrix(fileName,'Sheet','Branch','Range','D5:P99');
    num_bch = size(mpc.branch,1);
    
    % Input generator information
    mpc.gen = readmatrix(fileName,'Sheet','Gen','Range','E5:N81');
    num_rl_gen = size(mpc.gen,1);
    
    % Set generation costs
    margCost = readmatrix(fileName, 'Sheet','Gen','Range','O5:O81');
    mpc.gencost = zeros(num_rl_gen,6);
    mpc.gencost(:,[1, 4]) = 2;
    mpc.gencost(1:num_rl_gen,5) = margCost;
    
    
    
    %% 3) Create demand profiles for all substations
    DFESIdx = readmatrix(fileName, 'Sheet', 'Bus', 'Range', 'C5:C54');
    nonzeroDemandBusIdx = zeros(sum(~isnan(DFESIdx)), 1); 
    demandIdx = zeros(sum(~isnan(DFESIdx)), 1);
    
    % Records the indices for buses that have associated demand and generation
    % data in DFES workbook.
    cnt = 1;
    for i = 1:length(mpc.bus(:, 1))
        if ~isnan(DFESIdx(i))
            nonzeroDemandBusIdx(cnt) = mpc.bus(i, 1);
            demandIdx(cnt) = DFESIdx(i);
            cnt = cnt + 1;
        end 
    end
    
    % Build a table to associate the MATPOWER bus indices with the substation
    % indices in DFES workbook
    busIdx_demandIdx = table(nonzeroDemandBusIdx, demandIdx, 'VariableNames', {'mpcBusIndex', 'DFESDemandIndex'});
    
    % Obtain all bus names in the DFES demand data sheet
    load("DFESWorkbookRowName.mat");
    % Extract bus names that are included in this project
    DFESBusNames = DFESWorkbookRowName(demandIdx); 
    % Add these bus names to the predefined table and name this new column
    busIdx_demandIdx_DFESBusName = [busIdx_demandIdx, DFESBusNames];
    busIdx_demandIdx_DFESBusName = renamevars(busIdx_demandIdx_DFESBusName, 'Var3', 'DFESBusNames');
    
    % Build a cell to store bus names and corresponding load profiles
    demandProfiles = cell(length(demandIdx), 2);
    
    % Load maximum and minimum demand data
    load('MaximumDemandDatabase.mat');
    load('MinimumDemandDatabase.mat');
    
    % Loop to create demand profiles for each substation with specified parameters
    for i = 1:length(demandProfiles)
        busName_temp = busIdx_demandIdx_DFESBusName.DFESBusNames{i};
        % add bus name to the 1st column
        demandProfiles{i, 1} = busName_temp;
        % generate profiles with Best View scenario and add it to the 2nd column
        demandProfiles{i, 2} = GenerateDemandProfile(fileName, busName_temp, scenarioIdx, maxDemandDatabaseCell, ...
                                                     minDemandDatabaseCell, 'days', days, 'resolutionHours', resolutionHours, ...
                                                     'yearNumber', yearNumber, 'yearVariation', startSeason, ...
                                                     'readProfileStartIndex', readProfileStartIndex);
    end
    
    % Scale the demand if instructed
    if ifScaleDemand
        for i = 1:size(demandProfiles, 1)
            demandProfiles{i, 2} = demandProfiles{i, 2} * demandScaler;
        end
    end
    
    
    %% 4) Import DFES generation data
    % Initialise a space to store generation data
    generationData = zeros(length(nonzeroDemandBusIdx), 30); % '30' represents all years 2022 to 2051
    % Load DFES generation data
    load('GenerationDatabase.mat');
    % Iterate over every bus with non-zero demand (which has associated DFES generation data)
    for i = 1:length(nonzeroDemandBusIdx)
        % extract DFES generation data
        busName_temp = busIdx_demandIdx_DFESBusName.DFESBusNames{i};
        generationData(i, :) = GetDFESGeneration(busName_temp, scenarioIdx, generationDatabaseCell);
        % assign generation data to non-zero-demand buses depending on the year number
        idx_temp = num_rl_gen - length(nonzeroDemandBusIdx) + i;
        mpc.gen(idx_temp, 9) = generationData(i, yearNumber);
    end
    
    
    %% 5) Set up virtual generators (for load curtailment analysis)
    % initialise virtual generators structures
    num_vt_gen = size(demandProfiles, 1);
    mpc_vt_gen = zeros(size(demandProfiles, 1), size(mpc.gen, 2));
    mpc_vt_gencost = zeros(size(demandProfiles, 1), 6);
    % set gen parameters
    mpc_vt_gen(:, 1) = busIdx_demandIdx_DFESBusName.mpcBusIndex; % same to bus indices
    mpc_vt_gen(:, [6, 8]) = 1;
    mpc_vt_gen(:, 7) = mpc.baseMVA;
    for i = 1:size(demandProfiles, 1)
        mpc_vt_gen(i, 9) = 1.05 * max(demandProfiles{i, 2});
    end
    % set gencost parameters
    mpc_vt_gencost(:,[1, 4]) = 2;
    mpc_vt_gencost(1:num_vt_gen, 5) = 10000; % ensures virtual generators are used only when absolutely necessary
    % concatenate virtual generators to mpc.gen matrix
    mpc.gen = [mpc.gen; mpc_vt_gen];
    mpc.gencost = [mpc.gencost; mpc_vt_gencost];
    
    
    %% 6) Sample TTF and TTR for all transmission lines
    branchStates = SampleBranchStates(size(mpc.branch, 1), days*24, failureRate, repairRate);
    
    %% 7) Simulation
    % Calculate simulation parameters
    numTimeSteps = floor(days * 24 / resolutionHours);
    
    % Specify transmission lines that won't fail
    branchWontFail = readmatrix(fileName,'Sheet','Branch','Range','Q5:Q99');
    
    % Initialisation
    ENS_bus = zeros(num_vt_gen, numTimeSteps); % loss of load every time step at each bus
    ENS_total = zeros(1, numTimeSteps); % loss of load every time step of the whole network
    flgConverge = zeros(1, numTimeSteps);
    
    % Loop to simulate the network over time
    for t = 1:resolutionHours:(days*24)
        
        % update demand data at substations with non-zero demand
        for i = 1:length(nonzeroDemandBusIdx)
            mpc.bus(nonzeroDemandBusIdx(i), 3) = demandProfiles{i, 2}(t);
        end
    
        if ifSwitchBranches
            % update the state of transmission lines
            for i = 1:size(mpc.branch, 1)
                if ~ismember(i, branchWontFail)
                    mpc.branch(i, 11) = branchStates(i, t);
                end
            end
        end
    
        % run dc optimal power flow
        results = rundcopf(mpc);
        flgConverge(t) = results.success;
    
        % iterate over every virtual generator
        for i = 1:num_vt_gen
            % record curtailed load at each bus
            if results.gen(num_rl_gen+i, 2) > 1e-3
                ENS_bus(i, t) = results.gen(num_rl_gen+i, 2);
                % calculate total curtailed load of the network
                ENS_total(t) = ENS_total(t) + ENS_bus(i, t);
            end        
        end
    end
    
    
    %% 8) Results post processing and visualisation
    % Calculate DLC (duration of load curtailment) and FLC (frequency of ...)
    DLC = zeros(num_vt_gen, 1);
    FLC = zeros(num_vt_gen, 1);
    for i = 1:num_vt_gen
        DLC(i) = sum(nnz(ENS_bus(i, :))) * resolutionHours;
        FLC(i) = GetFLC(ENS_bus(i, :));
    end
    
    % Rewrite the results into tables
    % change LOL_bus from an array to a table and name rows and columns
    ENS_bus = array2table(ENS_bus);
    ENS_bus.Properties.RowNames = busIdx_demandIdx_DFESBusName.DFESBusNames;
    variableNames = arrayfun(@(x) [num2str(x)], resolutionHours:resolutionHours:days*24, 'UniformOutput', false);
    ENS_bus.Properties.VariableNames = variableNames;
    
    if ifPlotResults
        % Plot LOL of the whole network against time (line graph)
        plot(1:numTimeSteps, ENS_total, '-o', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'y', 'LineWidth', 1.5);
        xlabel('Time Step');
        ylabel('Total Curtailed Load (MW)');
        title('Total Load Curtailment Over Time');
        
        % Plot ENS of all stations against time (heatmap)
        % Generate row and column labels for the heatmap
        % HM_busNames = busIdx_demandIdx_DFESBusName.DFESBusNames; % Row labels (stations)
        % HM_timeLabels = arrayfun(@(x) ['Hour' num2str(x)], resolutionHours:resolutionHours:days*24, 'UniformOutput', false); % Column labels
        
        % Create the heatmap
        figure; % Create a new figure
        HM = heatmap(ENS_bus.Properties.VariableNames, ENS_bus.Properties.RowNames, ENS_bus{:,:});
        
        % Customize the heatmap
        HM.Title = 'ENS (in MW)';
        HM.XLabel = 'Timestep (in Hour)';
        HM.YLabel = 'Substations';
        HM.Colormap = parula; % You can choose other colormaps like 'jet', 'hot', etc.
        HM.ColorScaling = 'scaled'; % Adjusts the color scaling
    end
    
    
    %% 9) Write results into .mat files
    switch startSeason
        case 1 
            tempName = '_spring';
        case 2
            tempName = '_summer';
        case 3
            tempName = '_fall';
        case 4
            tempName = '_winter';
        case 5
            tempName = ['_from_' num2str(readProfileStartIndex)];
    end
    
    if ifWriteResults
        outputFileName = ['Results/','scenario_', num2str(scenarioIdx), '_year', num2str(yearNumber + 2021), ...
                          '_days' num2str(days), tempName, '.mat'];
        save(outputFileName, 'ENS_bus', 'ENS_total', 'DLC', 'FLC');
    end
    
    elapsedTime = toc;



end