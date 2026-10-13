# NJ Solar + Battery Simulator

A MATLAB simulation of solar production and household electricity use for a hypothetical home in Eatontown, NJ. The model uses 8,760 hourly intervals to compare grid-only, solar-only, and solar-plus-battery systems.

**Status:** Data processing, hourly energy flows, battery dispatch, three plots, and preliminary annual billing and savings calculations are implemented. Battery validation, utility-specific billing, payback, and sizing analysis are next.

## Results

Household electricity use is **10,000.0 kWh/year**, and solar production is **9,679.3 kWh/year**.

| Annual metric | Grid only | Solar only | Solar + battery |
| --- | ---: | ---: | ---: |
| Grid imports | 10,000.0 kWh | 6,334.3 kWh | 1,485.1 kWh |
| Grid exports | 0.0 kWh | 6,013.6 kWh | 640.6 kWh |
| Net grid imports | 10,000.0 kWh | 320.7 kWh | 844.6 kWh |
| Electricity bill | $2,320.00 | $190.55 | $305.80 |
| Savings versus grid only | — | $2,129.45 | $2,014.20 |

For solar only, **3,665.7 kWh** is used directly by the house. Solar self-consumption is **37.9%**, and household self-sufficiency is **36.7%**.

The battery reduces grid imports by approximately **76.6% compared with solar only**, but increases the modeled annual bill by **$115.25**. Under equal flat-rate retail credits, exporting solar already offsets later imports. Battery conversion losses and any increase in year-end stored energy therefore increase net consumption without providing a price advantage.

These financial results use assumed rates and simplified annual netting, not a verified utility tariff. Energy totals are calculated before rounding.

## Figures

1. [Winter and summer hourly plots](Figure_1.pdf) — solar production and household demand for January 1–7 and July 1–7.
2. [Monthly usage and solar production](Figure_2.pdf) — household demand and solar generation by month.
3. [Monthly grid imports and exports with battery](Figure%203.png) — grid energy flows after battery dispatch.

![Monthly grid imports and exports with battery](Figure%203.png)

Monthly totals are calculated from hourly data using `accumarray`.

## How to Run

Keep these files in the same MATLAB folder:

- `SolarProductionData.m`
- `SolarEconomics.m`
- `eatontown_pv_7kW_hourly.csv`
- `eatontown_synthetic_load_10000kWh_hourly.csv`

Run the energy simulation:

```matlab
SolarProductionData
```

Or run the energy simulation and economics together:

```matlab
SolarEconomics
```

`SolarEconomics.m` calls `SolarProductionData.m` before calculating bills and savings.

The energy script checks data length, hourly alignment, and solar-only energy conservation. It calculates baseline and battery energy flows and generates Figures 1–3. The battery function is defined locally in `SolarProductionData.m`.

## Project Files

| File | Purpose |
| --- | --- |
| `SolarProductionData.m` | Imports data, checks alignment, calculates energy flows, runs battery dispatch, and generates plots |
| `SolarEconomics.m` | Calculates annual bills and savings using assumed rates |
| `eatontown_pv_7kW_hourly.csv` | PVWatts hourly solar output and system metadata |
| `eatontown_synthetic_load_10000kWh_hourly.csv` | Synthetic household usage totaling 10,000 kWh/year |
| `Figure_1.pdf` | Winter and summer weekly profiles |
| `Figure_2.pdf` | Monthly household usage and solar production |
| `Figure 3.png` | Monthly grid imports and exports with battery |
| `README.md` | Setup, assumptions, results, and planned work |

## Energy-Flow Calculations

The grid-only baseline supplies all household demand from the grid.

For solar only:

```matlab
gridOnlyImport = demand;

netDemand = demand - pv;
gridImport = max(netDemand, 0);
gridExport = max(-netDemand, 0);
directSolarUse = min(pv, demand);
```

Positive net demand requires grid electricity. Negative net demand represents surplus solar available for export.

Performance measures are:

```text
Self-consumption (%) = 100 × direct solar use / total solar production

Self-sufficiency (%) = 100 × direct solar use / total household usage
```

Solar-only energy conservation is checked for every hour:

```text
Solar production + grid import = household demand + grid export
```

Annual net imports equal total imports minus total exports. They are distinct from gross imports because imports and exports occur at different hours.

## Battery Model

The current function call is:

```matlab
[stored, charge, discharge, batteryGridImport, batteryGridExport] = ...
    batteryModel(pv, demand, 40, 5, 0.95);
```

For each hour:

1. Solar supplies household demand first.
2. Surplus solar charges the battery within its power and capacity limits. Remaining surplus is exported.
3. During a deficit, the battery supplies energy available above its reserve. The grid supplies the remaining demand.
4. Stored energy is recorded at the end of the hour.

The battery charges only from surplus solar. Dispatch does not depend on electricity prices.

| Parameter | Current value |
| --- | --- |
| Capacity | 40 kWh |
| Charge/discharge power limit | 5 kW |
| Charging efficiency | 95% |
| Discharging efficiency | 95% |
| Round-trip efficiency | 90.25% |
| Minimum and initial stored energy | 4 kWh |
| Usable capacity | 36 kWh |

Charging adds `charge * efficiency` to stored energy. Discharging removes `discharge / efficiency`. Applying 95% efficiency in both directions gives 90.25% round-trip efficiency.

The battery starts at its 10% reserve. The final stored energy is not forced to equal the initial value.

| Output | Meaning |
| --- | --- |
| `stored` | Stored energy at the end of each hour |
| `charge` | Solar energy entering the battery before charging losses |
| `discharge` | Battery energy delivered to the house after discharge losses |
| `batteryGridImport` | Remaining household demand supplied by the grid |
| `batteryGridExport` | Remaining solar surplus exported to the grid |

Each output contains 8,760 hourly values in kWh. Annual and monthly totals are obtained by summing these values.

The 5 kW power limit permits up to 5 kWh of charging or discharging during a one-hour interval. Changing the time step would require updating the power-to-energy conversion.

## Billing and Savings Model

The preliminary model uses these assumptions:

| Parameter | Assumed value |
| --- | --- |
| Retail electricity rate | $0.22/kWh |
| Annual excess compensation | $0.05/kWh |
| Fixed monthly charge | $10 |
| Fixed annual charge | $120 |
| Settlement approach | Simplified annual netting |

Annual net consumption is calculated as:

```matlab
netUsage = annualImports - annualExports;
```

Positive net consumption is charged at the retail rate. Annual net surplus receives the assumed wholesale compensation:

```matlab
annualBill = max(netUsage, 0) * retailRate ...
    - max(-netUsage, 0) * wholesaleRate ...
    + annualFixedCharge;
```

Savings are calculated as:

```matlab
annualSolarSavings = baselineCost - solarOnlyCost;
batterySavingVsGrid = baselineCost - batteryCost;
batteryExtraSavings = solarOnlyCost - batteryCost;
```

Both solar scenarios have positive annual net consumption, so the wholesale compensation rate does not affect the current results.

The model approximates retail-credit net metering over a full year. Monthly credit banking, settlement timing, minimum bills, and utility-specific charges remain to be implemented. The rates above are study assumptions.

## Data and Assumptions

**Solar production:** [PVWatts Calculator](https://pvwatts.nlr.gov/), configured for Eatontown, NJ. The `AC System Output (W)` column is converted to energy for each one-hour interval:

```text
Solar energy (kWh) = AC output (W) / 1000 × 1 hour
```

**Household usage:** A synthetic profile with assumed morning and evening peaks, day-to-day variation, and higher summer usage, scaled to exactly 10,000 kWh/year. The `Load_kWh` column contains hourly consumption.

The household profile is not measured data, a verified Eatontown average, or an OpenEI/NREL residential load dataset.

| Parameter | Value |
| --- | --- |
| Location | Eatontown, NJ |
| Solar capacity | 7 kW DC |
| Mounting | Fixed rooftop |
| Module type | Standard |
| Tilt / azimuth | 25° / 180° |
| System losses | 14.08% |
| DC-to-AC size ratio | 1.2 |
| Inverter efficiency | 96% |
| Time step | 1 hour |
| Battery capacity | 40 kWh |

## Limitations

- Household consumption is synthetic, so results depend on assumed usage patterns.
- Solar production is modeled rather than measured from an installed system.
- A single annual solar profile does not capture variation between weather years.
- The battery uses fixed capacity, power limits, and efficiencies. It does not include degradation, self-discharge, temperature effects, or outage operation.
- Initial and final battery energy may differ, affecting annual comparisons.
- Billing uses assumed prices and simplified annual netting.
- Installed costs and payback have not yet been calculated.

## Next Steps

- Validate battery energy conservation and stored-energy limits.
- Check the effect of initial and final battery charge on annual results.
- Implement verified utility tariffs and monthly net-metering rules.
- Add installed costs, applicable incentives, and simple payback.
- Compare solar and battery sizes, including a 13.5 kWh battery.
- Present sizing results and final conclusions.

## Authors

- **Harmanjot Singh:** Battery modeling and simulation logic.
- **Matthew Cain:** Data processing and cost analysis.

Engineering students at Brookdale Community College.
