# NJ Solar + Battery Simulator

A MATLAB project modeling hourly solar production and household electricity use for a hypothetical home in Eatontown, Monmouth County, New Jersey. The study uses 8,760 hourly time steps and will compare grid-only, solar-only, and solar-plus-battery systems to evaluate energy use, system sizing, and payback.

**Status:** Data import, alignment checks, and winter/summer weekly plots are complete. Grid-flow calculations, battery dispatch, billing, and sizing analysis are the next stages.

## Current Results

### Winter and Summer Weekly Profiles

The plots compare hourly solar production and household
electricity use for January 1–7 and July 1–7.

[View winter and summer graphs (PDF)](Figure_1.pdf)

| Metric | Value |
| --- | --- |
| Hourly records per dataset | 8,760 |
| Estimated annual solar production | 9,679.3 kWh |
| Assumed annual household electricity use | 10,000 kWh |
| Maximum hourly AC output | 5.83 kW |

The import script checks that both datasets contain 8,760 values and that their month, day, and hour columns match. It prints annual totals and plots January 1–7 and July 1–7.

Annual production alone does not establish how much household demand solar covers. Generation and consumption must be compared hour by hour. The most cost-effective solar and battery sizes have not yet been determined.

## Completed Features

- Import hourly solar output and synthetic household usage from CSV files.
- Convert solar AC output from watts to kWh for each one-hour interval.
- Check dataset lengths and matching hourly labels.
- Print annual solar production and household consumption.
- Plot solar production against household usage for one winter week and one summer week.

## How to Run

1. Clone or download this repository.
2. Place these files in the same folder:
   - `SolarProductionData.m`
   - `eatontown_pv_7kW_hourly.csv`
   - `eatontown_synthetic_load_10000kWh_hourly.csv`
3. Open MATLAB and select that folder as the Current Folder. In MATLAB Online, upload all three files into the same folder.
4. Run the script from the Editor or enter this in the Command Window:

```matlab
SolarProductionData
```

The script should print approximately 9,679.3 kWh of annual solar production and 10,000.0 kWh of annual household usage, then display two weekly plots.

## Current Project Files

| File | Purpose |
| --- | --- |
| `SolarProductionData.m` | Imports data, checks hourly alignment, prints totals, and creates weekly plots |
| `eatontown_pv_7kW_hourly.csv` | Original PVWatts hourly solar output and system metadata |
| `eatontown_synthetic_load_10000kWh_hourly.csv` | Synthetic household electricity use totaling 10,000 kWh/year |
| `README.md` | Project setup, assumptions, progress, and planned work |

## Data Sources

**Solar production:** [PVWatts Calculator](https://pvwatts.nlr.gov/), configured for Eatontown, NJ, using solar resource coordinates 40.29° N, 74.06° W. The downloaded `AC System Output (W)` column supplies solar output.

For each one-hour interval:

```text
Solar energy (kWh) = AC output (W) / 1000 × 1 hour
```

**Household usage:** A custom synthetic profile generated for this project's preliminary development. It includes assumed morning and evening peaks, day-to-day variation, and higher summer usage, scaled to exactly 10,000 kWh/year. Its `Load_kWh` column contains hourly energy consumption.

This is not measured household usage, a verified Eatontown average, or an OpenEI/NREL residential load dataset.

**Electricity rates and incentives:** Not yet selected or implemented. Applicable utility tariffs, net-metering rules, installed costs, and incentives will be documented during the economics stage.

## Assumptions

| Parameter | Value | Status |
| --- | --- | --- |
| Study location | Eatontown, NJ | Current |
| Annual household consumption | 10,000 kWh | Assumed; synthetic profile |
| Solar array size | 7 kW DC | Current |
| Module type | Standard | Current |
| Array type | Fixed, roof mounted | Current |
| Tilt | 25° | Current |
| Azimuth | 180° (south) | Current |
| System losses | 14.08% | From PVWatts export |
| DC-to-AC size ratio | 1.2 | From PVWatts export |
| Inverter efficiency | 96% | From PVWatts export |
| Time step | 1 hour | Current |
| Battery capacity | 13.5 kWh | Planned starting value |
| Battery maximum charge/discharge power | 5 kW | Planned starting value |
| Battery round-trip efficiency | 90% | Planned starting value |
| Minimum battery state of charge | 10% | Planned starting value |

## Next Steps

1. Calculate grid-only electricity imports as a baseline.
2. Calculate solar-only imports, exports, self-consumption, and self-sufficiency.
3. Implement hourly battery charging and discharging with energy, power, reserve, and efficiency limits.
4. Validate energy conservation and battery limits, including the effect of initial and final stored energy.
5. Implement the applicable tariff and net-metering billing rules. Include time-of-use pricing if available, or clearly label it as a hypothetical scenario.
6. Evaluate annual savings, total-system simple payback, and incremental battery payback relative to solar alone.
7. Sweep solar sizes from 4–12 kW and battery capacities from 0–20 kWh, including solar-only configurations.
8. Export weekly energy-flow plots, battery SOC plots, monthly energy bars, and a payback heatmap.

As the project grows, the code can be separated into data-loading, battery-simulation, billing, and sizing functions. Those functions are planned and are not part of the current run instructions.

## Limitations and Future Extensions

- Household consumption uses assumed patterns and has not been validated against measured local usage. Financial and sizing conclusions will depend on this assumption.
- Solar production is modeled, rather than measured from an installed system. A single annual profile does not capture the full variation between weather years.
- Grid flows, battery behavior, costs, and payback have not yet been calculated.
- Planned extensions include price-aware dispatch, measured or externally sourced household profiles, and battery degradation and replacement costs.

## Authors

- **Harmanjot Singh:** Battery dispatch model and simulation logic.
- **Matthew Cain:** Data processing and cost analysis.

Engineering students at Brookdale Community College. Responsibilities describe the agreed project split; planned features will be documented as they are completed.
