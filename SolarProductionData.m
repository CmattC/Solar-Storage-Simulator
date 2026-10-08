
% Import solar data: column headings begin on line 32
solar = readtable('eatontown_pv_7kW_hourly.csv.csv', ...
    'NumHeaderLines', 31, 'VariableNamingRule', 'preserve');

% Import household usage into a table
house = readtable('eatontown_synthetic_load_10000kWh_hourly.csv');

% Convert solar output to kWh for each one-hour interval
pv = solar.("AC System Output (W)") / 1000;
demand = house.Load_kWh;

% Check that both vectors contain 8,760 values
assert(numel(pv) == 8760 && numel(demand) == 8760);

% Check that the month, day, and hour match between files
assert(isequal(solar.Month, house.Month) && ...
    isequal(solar.Day, house.Day) && ...
    isequal(solar.Hour, house.Hour));

% Print annual totals
fprintf('Annual solar production: %.1f kWh\n', sum(pv));
fprintf('Annual household usage: %.1f kWh\n', sum(demand));

% Plot January 1–7 and July 1–7
figure;
months = [1, 7];
titles = {'Winter: January 1-7', 'Summer: July 1-7'};

% First pass selects January; second pass selects July
for k = 1:2
    idx = house.Month == months(k) & house.Day <= 7;

    subplot(2, 1, k);
    plot(0:167, pv(idx), 0:167, demand(idx));

    title(titles{k});
    xlabel('Hours from start of week');
    ylabel('Energy per hour (kWh)');
    legend('Solar production', 'Household usage');
    grid on;
end