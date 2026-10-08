# NJ Solar + Battery Simulator

A MATLAB simulation of solar production and household electricity use for a hypothetical home in Eatontown, NJ. The model uses 8,760 hourly intervals to compare grid-only, solar-only, and solar-plus-battery systems.

**Status:** Data processing, grid-only and solar-only calculations, and weekly/monthly plots are complete. Battery modeling and economics are next.

## Results

| Metric | Annual result |
| --- | --- |
| Household electricity use | 10,000.0 kWh |
| Solar production | 9,679.3 kWh |
| Solar used directly | Approximately 3,665.7 kWh |
| Grid imports with solar | Approximately 6,334.3 kWh |
| Grid exports | 6,013.6 kWh |
| Solar self-consumption | 37.9% |
| Household self-sufficiency | 36.7% |

Solar production nearly matches annual household usage, but differences in timing mean the home still imports electricity.

- [Winter and summer hourly plots](Figure_1.pdf)
- [Monthly usage and solar production](Figure_2.pdf)

## How to Run

Keep these files in the same MATLAB folder:

- `SolarProductionData.m`
- `eatontown_pv_7kW_hourly.csv`
- `eatontown_synthetic_load_10000kWh_hourly.csv`

Run:

```matlab
SolarProductionData
```

The script checks hourly alignment and energy balance, prints annual results, and generates the plots.

## Data and Assumptions

Solar output comes from [PVWatts](https://pvwatts.nlr.gov/). Household usage is synthetic, with assumed daily and seasonal patterns scaled to 10,000 kWh/year.

| Parameter | Value |
| --- | --- |
| Solar capacity | 7 kW DC |
| Mounting | Fixed rooftop |
| Tilt / azimuth | 25° / 180° |
| Time step | 1 hour |
| Planned battery capacity | 13.5 kWh |
| Planned battery power limit | 5 kW |
| Planned round-trip efficiency | 90% |
| Planned minimum state of charge | 10% |

Current results exclude battery storage. The household profile is not measured data, and costs and payback have not yet been calculated.

## Next Steps

- Build and validate the battery model.
- Model electricity rates, net metering, savings, and payback.
- Compare solar and battery sizes and present final results.

## Authors

- **Harmanjot Singh:** Battery modeling and simulation logic.
- **Matthew Cain:** Data processing and cost analysis.

Engineering students at Brookdale Community College.
