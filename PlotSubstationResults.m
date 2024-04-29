clear;
clc;
close all;

scenarioIdx = 5;

switch scenarioIdx
    case 1
        strTemp = 'BestView';
    case 2
        strTemp = 'FallingShort';
    case 3
        strTemp = 'SystemTransformation';
    case 4
        strTemp = 'ConsumerTransformation';
    case 5
        strTemp = 'LeadingTheWay';
end


%% 1) Plot heatmap

ifPlotHeatmap = 0; % toggle for plotting the heatmap

% specify year number
yearNumber = 2050;
days = 7;

if ifPlotHeatmap    
    % load weekly results data with specified year number
    fileName = ['Results/', strTemp, '_year/scenario_', num2str(scenarioIdx), '_year', num2str(yearNumber), ...
                '_days', num2str(days), '_winter.mat'];
    load(fileName);
    % discard stations at BSP level (won't subject to load curtailments)
    LOL_bus_subset = LOL_bus(10:41, :);
    % plot heatmap
    figure;
    HM = heatmap(LOL_bus_subset.Properties.VariableNames, LOL_bus_subset.Properties.RowNames, LOL_bus_subset{:,:});
    % customize the heatmap
    HM.Title = 'Load Curtailment (MW) by Station and Time';
    HM.XLabel = 'Time Step (Hour No.)';
    HM.YLabel = 'Station';
    HM.Colormap = parula; % can specify other colormaps like 'jet', 'hot', etc.
    HM.ColorScaling = 'scaled'; % adjusts the color scaling
end


%% 2) Plot yearly EENS, EDLC and EFLC for specified substations

% Initialisation

% toggles for plotting each index
ifPlotEENS = 1;
ifPlotEDLC = 1;
ifPlotEFLC = 1;

% specify year number and substation names
startYearNumber = 2023;
endYearNumber = 2050;

stationNames = {'Didsbury', 'Queens Park','Whalley Range'};

% Load yearly results data with specified year number
fileName = ['Results_Indices/', strTemp, '_year/indices_scenario_', num2str(scenarioIdx), '_year', ...
            num2str(startYearNumber), '-', num2str(endYearNumber), '_days365_winter.mat'];
load(fileName);

% Prepare a string variable for the graph title
switch scenarioIdx
    case 1
        scenarioName = 'Best View';
    case 2
        scenarioName = 'Falling Short';
    case 3
        scenarioName = 'System Transformation';
    case 4
        scenarioName = 'Consumer Transformation';
    case 5
        scenarioName = 'Leading The Way';
end

% Plot EENS
if ifPlotEENS
    % initialisation
    x = startYearNumber:endYearNumber;
    numYVars = size(stationNames, 2);
    
    % generate distinct colors
    colors = lines(numYVars);
    
    % plotting
    figure; % Create a new figure window
    hold on; % Retain plots on the same axes
    grid on;
    for i = 1:numYVars
        substationEENS = EENS_table{stationNames{i}, :};
        plot(x, substationEENS/1000, 'Color', colors(i, :), 'DisplayName', stationNames{i}, 'LineWidth', 2);
    end
    
    % Adjust the starting and ending points on the x-axis
    xlim([startYearNumber, endYearNumber]);
    
    % Add a legend
    legend('show');
    legend('Location', 'best'); % Adjust the legend location as needed
    legend('FontSize', 18);
    
    % Additional customizations
    xlabel('Year', 'FontSize', 16); % Label for the x-axis
    ylabel('EENS (GWh/year)', 'FontSize', 16); % Label for the y-axis
    title(['EENS vs Year in ', scenarioName, ' Scenario'], 'FontSize', 18); % Title for the plot
    ax = gca;
    ax.FontSize = 16;
    ax.YAxis.Exponent = 0; % turn off the scientific notation
    
    hold off;
end


% Plot EDLC
if ifPlotEDLC
    % initialisation
    x = startYearNumber:endYearNumber;
    numYVars = size(stationNames, 2);
    
    % generate distinct colors
    colors = lines(numYVars);
    
    % plotting
    figure; % Create a new figure window
    hold on; % Retain plots on the same axes
    grid on;
    for i = 1:numYVars
        substationEDLC = EDLC_table{stationNames{i}, :};
        plot(x, substationEDLC, 'Color', colors(i, :), 'DisplayName', stationNames{i}, 'LineWidth', 2);
    end
    
    % Adjust the starting and ending points on the x-axis
    xlim([startYearNumber, endYearNumber]);
    
    % Add a legend
    legend('show');
    legend('Location', 'best'); % Adjust the legend location as needed
    legend('FontSize', 18);
    
    % Additional customizations
    xlabel('Year', 'FontSize', 16); % Label for the x-axis
    ylabel('DLC (hrs/year)', 'FontSize', 16); % Label for the y-axis
    title(['EDLC vs Year in ', scenarioName, ' Scenario'], 'FontSize', 18); % Title for the plot
    ax = gca;
    ax.FontSize = 16;
    ax.YAxis.Exponent = 0; % turn off the scientific notation
    
    hold off;
end


% Plot EFLC
if ifPlotEFLC
    % initialisation
    x = startYearNumber:endYearNumber;
    numYVars = size(stationNames, 2);
    
    % generate distinct colors
    colors = lines(numYVars);
    
    % plotting
    figure; % Create a new figure window
    hold on; % Retain plots on the same axes
    grid on;
    for i = 1:numYVars
        substationEFLC = EFLC_table{stationNames{i}, :};
        plot(x, substationEFLC, 'Color', colors(i, :), 'DisplayName', stationNames{i}, 'LineWidth', 2);
    end
    
    % Adjust the starting and ending points on the x-axis
    xlim([startYearNumber, endYearNumber]);
    
    % Add a legend
    legend('show');
    legend('Location', 'best'); % Adjust the legend location as needed
    legend('FontSize', 18);
    
    % Additional customizations
    xlabel('Year', 'FontSize', 16); % Label for the x-axis
    ylabel('FLC (occ./year)', 'FontSize', 16); % Label for the y-axis
    title(['EFLC vs Year in ', scenarioName, ' Scenario'], 'FontSize', 8); % Title for the plot
    ax = gca;
    ax.FontSize = 16;
    ax.YAxis.Exponent = 0; % turn off the scientific notation
    
    hold off;
end

