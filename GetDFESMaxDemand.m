function demandData = GetDFESMaxDemand(stationName, scenarioIdx, maxDemandDatabaseCell)
    
    % input: 1) the name of the station (a text string)
    %        2) the scenario index:
    %           1 -- Best View
    %           2 -- Falling Short
    %           3 -- System Transformation
    %           4 -- Customer Transformation
    %           5 -- Leading the Way
    % output: an array of maximum demand data at this station from 2022 to 2051    

    switch scenarioIdx
        case 1
            maxDemandDatabase = maxDemandDatabaseCell{1};
        case 2
            maxDemandDatabase = maxDemandDatabaseCell{2};
        case 3
            maxDemandDatabase = maxDemandDatabaseCell{3};
        case 4
            maxDemandDatabase = maxDemandDatabaseCell{4};
        case 5
            maxDemandDatabase = maxDemandDatabaseCell{5};
    end
    
    % Check if the stationName exists in the RowNames
    [flg, idx] = ismember(stationName, maxDemandDatabase.Properties.RowNames);
    
    if flg
        % If found, extract the corresponding row as demandData
        demandData = table2array(maxDemandDatabase(idx, :));
    else
        % If not found, display an error message
        disp(['Failed to find maximum demand data at ', stationName]);
    end

end