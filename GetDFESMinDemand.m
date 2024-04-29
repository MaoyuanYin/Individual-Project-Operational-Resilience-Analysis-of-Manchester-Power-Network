function demandData = GetDFESMinDemand(stationName, scenarioIdx, minDemandDatabaseCell)
    
    % input: 1) the name of the station (a text string)
    %        2) the scenario index:
    %           1 -- Best View
    %           2 -- Falling Short
    %           3 -- System Transformation
    %           4 -- Customer Transformation
    %           5 -- Leading the Way
    % output: an array of minimum demand data at this station from 2022 to 2051    

    switch scenarioIdx
        case 1
            minDemandDatabase = minDemandDatabaseCell{1};
        case 2
            minDemandDatabase = minDemandDatabaseCell{2};
        case 3
            minDemandDatabase = minDemandDatabaseCell{3};
        case 4
            minDemandDatabase = minDemandDatabaseCell{4};
        case 5
            minDemandDatabase = minDemandDatabaseCell{5};
    end
    
    % Check if the stationName exists in the RowNames
    [flg, idx] = ismember(stationName, minDemandDatabase.Properties.RowNames);
    
    if flg
        % If found, extract the corresponding row as demandData
        demandData = table2array(minDemandDatabase(idx, :));
    else
        % If not found, display an error message
        disp(['Failed to find minimum demand data at ', stationName]);
    end

end