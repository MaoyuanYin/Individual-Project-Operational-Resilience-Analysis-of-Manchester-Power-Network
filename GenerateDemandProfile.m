function Profile = GenerateDemandProfile(fileName, stationName, scenarioIdx, maxDemandDatabaseCell, minDemandDatabaseCell, varargin)
    % Input:
    %   1) stationName: the name of substation that is considered
    %   2) scenarioIdx: 1 --> BV, 2 --> FS, 3 --> CT, 4 --> ST, 5 --> LTW
    %   3) days: the time period in days of the output profile (integer and maximum 365)
    %            Note: the maximum allowable value of 'days' may vary depending on 'yearVariation'
    %   4) resolutionHours: the resolution in half-hours of the output profile (0.5, 1, 2...)
    %   5) yearNumber: 1 --> 2022, 2 --> 2023, ... 30 --> 2051
    %   6) yearVariation:
    %           profiles starts from: 
    %               1 --> first historical data point ('days' should <= 365)
    %               2 --> peak demand day ('days' should <= 340)
    %               3 --> lowest demand day ('days' should <= 7)


    % Output:
    %   the demand profile with specified requirements
    
    % Set default values of optional input parameters (period = 365 days, resolution = half-hour) 
    p = inputParser;
    addRequired(p, 'stationName', @(x) ischar(x) || isstring(x));
    addRequired(p, 'scenarioIdx', @isnumeric);
    addParameter(p, 'days', 365, @isnumeric);
    addParameter(p, 'resolutionHours', 1, @isnumeric);
    addParameter(p, 'yearNumber', 1, @isnumeric);
    addParameter(p, 'yearVariation', 1, @isnumeric);
    addParameter(p, 'readProfileStartIndex', 1, @isnumeric);
    parse(p, stationName, scenarioIdx, varargin{:});
    days = p.Results.days;
    resolutionHours = p.Results.resolutionHours;
    yearNumber = p.Results.yearNumber;
    yearVariation = p.Results.yearVariation;
    readProfileStartIndex = p.Results.readProfileStartIndex;

    % Read historical load (an half-hourly profile over 1 year period)
    idx = readmatrix(fileName, 'Sheet', 'HISTORICAL LOAD', 'Range', 'B7:B17526');
    historicalProfile = readmatrix(fileName, 'Sheet', 'HISTORICAL LOAD', 'Range', 'D7:D17526');
    
    % Read maximum and minimum demand at a specified substation
    maxDemandData = GetDFESMaxDemand(stationName, scenarioIdx, maxDemandDatabaseCell);
    minDemandData = GetDFESMinDemand(stationName, scenarioIdx, minDemandDatabaseCell);
    maxDemand = maxDemandData(yearNumber);
    minDemand = minDemandData(yearNumber);
    
    % Identify the peak and trough values
    peakHistorical = max(historicalProfile);
    troughHistorical = min(historicalProfile);
    
    % Normalize the profile
    normalizedProfile = (historicalProfile - troughHistorical) / (peakHistorical - troughHistorical);
    
    % Scale the profile to match your maximum and minimum demand values
    scaledProfile = normalizedProfile * (maxDemand - minDemand) + minDemand;

    % Extract a subset profile from the original profile based on parameters 'days' and 'resolutionHours'
    stepSize = resolutionHours * 2;
    totalPoints = (days * 24 / resolutionHours);
    Profile = zeros(totalPoints, 1);
    for i = 1:totalPoints
        % Calculate the index in the original profile for the current point
        if yearVariation == 1
            index = (i - 1) * stepSize + 1 + 2880;
        elseif yearVariation == 2
            index = (i - 1) * stepSize + 1 + 7248;
        elseif yearVariation == 3
            index = (i - 1) * stepSize + 1 + 11616;
        elseif yearVariation == 4
            index = (i - 1) * stepSize + 1 + 15984;
        elseif yearVariation == 5
            index = (i - 1) * stepSize + readProfileStartIndex;
        end

        % Check if 'index' exceeds the length of the profile (i.e. 17520)
        index_temp = index; 
        while(index_temp > 17520)
            index_temp = index_temp - 17520;
        end
        % Assign the value from the original profile to the subset
        Profile(i) = scaledProfile(index_temp);

    end

end