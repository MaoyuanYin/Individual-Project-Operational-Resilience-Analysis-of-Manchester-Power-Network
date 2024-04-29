clear;
clc;
close all;

fileName = "Database_Manchester_Formatted.xlsx";

times = 1:8760;
loads = zeros(1, length(times));

historicalProfile = readmatrix(fileName, 'Sheet', 'HISTORICAL LOAD', 'Range', 'D7:D17526');
cnt = 1;
for i = 1:2:17520
    loads(cnt) = historicalProfile(i);
    cnt = cnt + 1;
end

figure;
plot(times, loads);
xlabel('Time (hr)', 'FontSize', 16);
ylabel('Historical Load', 'FontSize', 16);
title('Hourly One-year Historical Load Profile', 'FontSize', 20);