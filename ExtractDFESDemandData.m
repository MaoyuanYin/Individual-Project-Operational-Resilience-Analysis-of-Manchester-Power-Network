clear;

fileName = 'dfes-2022-workbook.xlsm';

% Maximum or Minimum Demand data sheet:
range_ps_BestView = 'D12:AG379';
range_bsp_BestView = 'D382:AG447';
range_ps_FallingShort = 'AI12:BL379';
range_bsp_FallingShort = 'AI382:BL447';
range_ps_SystemTransformation = 'BN12:CQ379';
range_bsp_SystemTransformation = 'BN382:CQ447';
range_ps_CustomerTransformation = 'CS12:DV379';
range_bsp_CustomerTransformation = 'CS382:DV447';
range_ps_LeadingTheWay = 'DX12:FA379';
range_bsp_LeadingTheWay = 'DX382:FA447';

% Extract station names (row variable names)
psNames = readcell(fileName,'Sheet', 'Minimum Demand', 'Range', 'B12:B379');
bspNames = readcell(fileName, 'Sheet', 'Minimum Demand', 'Range', 'B382:B447');
for i = 1:length(bspNames)
    for j = 1:length(psNames)
        if strcmp(bspNames{i, 1}, psNames{j, 1})
            bspNames{i, 1} = strcat(psNames{j, 1}, '_bsp');
        end
    end
end
stationNames = [psNames; bspNames];

% Extract year number (column variable names)
yearNumbers = string(readmatrix(fileName, 'Sheet', 'Minimum Demand', 'Range', 'D10:AG10'));

% Extract maximum demand data at a scenario
minDemand_PS = readtable(fileName, 'Sheet', 'Minimum Demand', 'Range', range_ps_SystemTransformation, 'ReadVariableNames', false);
minDemand_BSP = readtable(fileName, 'Sheet', 'Minimum Demand', 'Range', range_bsp_SystemTransformation, 'ReadVariableNames', false);
minDemand = [minDemand_PS; minDemand_BSP];

% Write the data into a table (specifying row and column names)
minDemand.Properties.RowNames = stationNames;
minDemand.Properties.VariableNames = yearNumbers;



