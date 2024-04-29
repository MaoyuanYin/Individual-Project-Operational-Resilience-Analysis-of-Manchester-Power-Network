function FLC = GetFLC(LOL_bus)
    % input: an 1D array that stores the load curtailment data in a period

    % output: the number of times of load curtailment in the period
    
    FLC = 0;
    temp = 0;
    for i = 1:length(LOL_bus)
        if temp == 0 && LOL_bus(i) ~= 0
            FLC = FLC + 1;
        end
        temp = LOL_bus(i);
    end

end