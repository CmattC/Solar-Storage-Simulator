% Import solar data: column headings begin on line 32
solar = readtable('eatontown_pv_7kW_hourly.csv', ...
    'NumHeaderLines', 31, 'Vari ableNamingRule', 'preserve');

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

%% Plot Annual difference Bar
annualDifference = sum(demand) - sum(pv);
fprintf('Annual energy difference %.1f kWh\n', annualDifference);

monthlyDemand = accumarray(house.Month, demand, [12, 1]);
monthlySolar = accumarray(solar.Month, pv, [12, 1]);

figure;
bar(1:12, [monthlyDemand, monthlySolar]);

xticks(1:12);
xticklabels({'Jan','Feb','Mar','May',"Jun",'Jul','Aug','Sep','Oct','Nov','Dec'});

xlabel('Month');
legend('Household usage','Solar production')
ylabel('Monthly Household Usage and Solar Production');
%title('Annual Hourly Energy Difference');
grid on;


%% Grid only baseline
%Without solar, the grid supplies all household usage
gridOnlyImport = demand;
annualGridOnlyImport = sum(gridOnlyImport);

%% Solar only energy flaws
%Positive = electricity deficit; negative = solar surplus
netDemand = demand - pv;

%Electricity purchased from the grid each hour
gridImport = max(netDemand, 0);

%Excess solar electricity sent to the grid each hour
gridExport = max(-netDemand, 0);

%Solar electricity used directly by the house
directSolarUse = min(pv, demand);

%% Annual energy totals
annualDemand = sum(demand);
annualSolar = sum(pv);
annualGridImport = sum(gridImport);
annualGridExport = sum(gridExport);
annualDirectSolar = sum(directSolarUse);

%% Solar performance measures
selfConsumption = 100*annualDirectSolar/annualSolar;
selfSufficiency = 100*annualDirectSolar/annualDemand;

%Solar + grid imports must equal demand + grid exports

balanceError = pv +gridImport - demand - gridExport;
assert(all(abs(balanceError)<1e-9), ... 
    'Hourly energy balance failed.');

fprintf('\n--- Grid and solar energy flows ---\n');
fprintf('Grid-only annual import: %.1f kWh\n', annualGridOnlyImport);
fprintf('Annual solar production: %.1f kWh\n', annualSolar);
fprintf('Solar used directly: %.1f kWh\n', annualDirectSolar);
fprintf('Solar-only grid import: %.1f kWh\n', annualGridImport);
fprintf('Solar-only grid export: %.1f kWh\n', annualGridExport);
fprintf('Solar self-consumption: %.1f%%\n', selfConsumption);
fprintf('Household self-sufficiency: %.1f%%\n', selfSufficiency);
