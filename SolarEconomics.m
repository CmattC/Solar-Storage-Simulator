SolarProductionData;

%% Billing assumptions
retailRate = .22; % $/kWh
wholesaleRate = .05; % $/kWh for annual excess
monthlyFixedCharge = 10; % $/month

annualFixedCharge = 12*monthlyFixedCharge;

%% Grid Only Billing

baselineCost = annualGridOnlyImport*retailRate ... 
    + annualFixedCharge;

%% Solar Only Billing

solarNetUsage = annualGridImport - annualGridExport;
 
% Pos net usage is purchased at retail
% Annual surplus receives the assumed wholesale compensation
solarOnlyCost = max(solarNetUsage, 0)* retailRate ...
    - max(-solarNetUsage, 0)* wholesaleRate ...
    + annualFixedCharge;

annualSolarSavings = baselineCost - solarOnlyCost;

%% Solar plus battery billing
batteryNetUsage = annualBatteryGridImport ...
    - annualBatteryGridExport;

batteryCost = max(batteryNetUsage, 0)*retailRate ...
    - max(-batteryNetUsage, 0)*wholesaleRate ...
    + annualFixedCharge;

batterySavingVsGrid = baselineCost - batteryCost;
batteryExtraSavings = solarOnlyCost - batteryCost;

%%Print annual bill comparison

fprintf('\n--- Annual Billing ---\n');
fprintf('Grid only bill $%.2f/year\n', baselineCost);
fprintf('Solar only bill $%.2f/year\n', solarOnlyCost);
fprintf('Solar plus battery bill $%.2f/year\n', batteryCost);

fprintf('Solar savings versus grid only: $%.2f/year\n', ...
    annualSolarSavings)
fprintf('Solar + battery saving versus grid only: $%.2f/year\n', ...
    batterySavingVsGrid);
fprintf('Additional battery savings versus solar only: $%.2f/year\n', ...
    batteryExtraSavings);

%% Operating Assumptions
