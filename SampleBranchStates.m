function branchStates = SampleBranchStates(numBranches, numHours, failureRatePerYear, repairRatePerYear)            
    
    failureRatePerHour = failureRatePerYear / 8760;
    repairRatePerHour = repairRatePerYear / 8760;
    branchStates = zeros(numBranches, numHours);

    % Iterate over each branch
    for i = 1:numBranches
        
        hourCnt = 1;
        % For each branch, compute TTF and TTR until total time exceeds 'numHours'
        while hourCnt <= numHours
            TTF = ceil(-1/failureRatePerHour * log(rand(1)));  % Time to failure (operational time)
            TTR = ceil(-1/repairRatePerHour * log(rand(1)));  % Time to repair (downtime)
    
            % Ensure we do not exceed the number of hours when setting states
            if hourCnt + TTF - 1 <= numHours
                branchStates(i, hourCnt:hourCnt + TTF - 1) = 1;  % Operational state
            else
                branchStates(i, hourCnt:end) = 1;  % Remain operational until the end if exceeding
                break;  % Exit the while loop
            end
            hourCnt = hourCnt + TTF;
    
            if hourCnt + TTR - 1 <= numHours
                branchStates(i, hourCnt:hourCnt + TTR - 1) = 0;  % Failed state
            else
                branchStates(i, hourCnt:end) = 0;  % Remain failed until the end if exceeding
                break;  % Exit the while loop
            end
            hourCnt = hourCnt + TTR;
        end
    end

end