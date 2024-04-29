function genrationData = GetDFESGeneration(stationName, scenarioIdx, generationDatabaseCell)
    
    % input: 1) the name of the station (a text string)
    %        2) the scenario index:
    %           1 -- Best View
    %           2 -- Falling Short
    %           3 -- System Transformation
    %           4 -- Customer Transformation
    %           5 -- Leading the Way
    % output: an array of generation data at this station from 2022 to 2051    

    switch scenarioIdx
        case 1
            generationDatabase = generationDatabaseCell{1};
        case 2
            generationDatabase = generationDatabaseCell{2};
        case 3
            generationDatabase = generationDatabaseCell{3};
        case 4
            generationDatabase = generationDatabaseCell{4};
        case 5
            generationDatabase = generationDatabaseCell{5};
    end
    
    % Check if the stationName exists in the RowNames
    [flg, idx] = ismember(stationName, generationDatabase.Properties.RowNames);
    
    if flg
        % If found, extract the corresponding row as demandData
        genrationData = table2array(generationDatabase(idx, :));
    else
        % If not found, display an error message
        disp(['Failed to find generation data at ', stationName]);
    end

end