# NJ Solar + Battery Simulator

A MATLAB simulation of solar production and household electricity use for a hypothetical home in Eatontown, NJ. The model uses 8,760 hourly intervals to compare grid-only, solar-only, and solar-plus-battery systems.

**Status:** Data processing, baseline energy calculations, the hourly battery model, annual battery import/export totals, and all three plots are implemented. Electricity pricing, savings, and payback analysis are next.

## Results

Household electricity use is **10,000.0 kWh/year**, and solar production is **9,679.3 kWh/year**.

| Annual metric | Grid only | Solar only | Solar + battery |
| --- | ---: | ---: | ---: |
| Grid imports | 10,000.0 kWh | 6,334.3 kWh | 1,485.1 kWh |
| Grid exports | 0.0 kWh | 6,013.6 kWh | 640.6 kWh |
| Net grid imports (imports - exports) | 10,000.0 kWh | 320.7 kWh | 844.6 kWh |

For the solar-only system, 3,665.7 kWh is used directly by the house. Solar self-consumption is 37.9%, and household self-sufficiency is 36.7%; these percentages describe the solar-only baseline.

The battery shifts surplus solar into hours when demand exceeds production, reducing annual grid imports by approximately **76.6% compared with solar only**. It also reduces exports. Net imports are higher than the solar-only net balance because storage introduces conversion losses and can retain energy at year-end. Net imports are an energy balance, not an electricity bill or a measure of gross grid dependence.

Results are rounded to one decimal place; net totals are calculated before rounding.

## Figures

1. [Figure 1: Winter and summer hourly plots](Figure_1.pdf) — solar production and household demand for January 1–7 and July 1–7.
2. [Figure 2: Monthly usage and solar production](Figure_2.pdf) — total household demand and solar generation for each month.
3. [Figure 3: Monthly grid imports and exports with battery](Figure%203.png) — grouped bars showing energy purchased from and exported to the grid after battery dispatch.

![Figure 3: Monthly grid imports and exports with battery](Figure%203.png)

Figure 3 sums the hourly battery grid flows by month with `accumarray`. Blue bars show imports and orange bars show exports; all monthly totals are in kWh.

## How to Run

Keep these files in the same MATLAB folder:

- `SolarProductionData.m`
- `eatontown_pv_7kW_hourly.csv`
- `eatontown_synthetic_load_10000kWh_hourly.csv`

Run:

```matlab
SolarProductionData
```

The script checks the 8,760-hour data length, timestamp alignment, and solar-only hourly energy balance. It prints baseline and battery annual results, calculates monthly totals, and generates Figures 1–3. The battery function is defined locally in `SolarProductionData.m`; the separate repository file `BatteryModel` is not required to run this script.

## Battery Model

The script calls:

```matlab
[stored, charge, discharge, batteryGridImport, batteryGridExport] = ...
    batteryModel(pv, demand, 40, 5, 0.95);
```

The function processes each hour in sequence:

1. Solar supplies household demand first.
2. Surplus solar charges the battery, limited by surplus energy, the charge limit, and remaining capacity. Any surplus left over is exported.
3. When solar is insufficient, the battery supplies the deficit, limited by the discharge limit and energy available above the reserve. The grid supplies the remaining deficit.
4. Stored energy is recorded at the end of the hour.

The battery charges only from surplus solar. There is no grid charging or electricity-price-based dispatch.

| Input | Meaning | Current value |
| --- | --- | --- |
| `pv` | Solar energy in each hourly interval | kWh, from the solar CSV |
| `demand` | Household energy in each hourly interval | kWh, from the load CSV |
| `capacity` | Maximum stored energy | 40 kWh |
| `maxPower` | Charge/discharge limit | 5 kW; 5 kWh per one-hour interval |
| `efficiency` | Efficiency applied separately to charging and discharging | 0.95 |

Charging adds `charge * efficiency` to stored energy. Delivering `discharge` to the house removes `discharge / efficiency` from the battery. Thus 95% efficiency in each direction gives **90.25% round-trip efficiency** (0.95 × 0.95).

The battery starts January 1 at its 10% reserve: **4 kWh**. It remains between 4 and 40 kWh, giving **36 kWh of usable storage**. The simulation does not force the final stored energy to equal the initial stored energy.

| Output in the script | Meaning |
| --- | --- |
| `stored` | Battery energy at the end of each hour, in kWh |
| `charge` | Surplus solar sent into the battery before charging losses, in kWh |
| `discharge` | Battery energy delivered to household demand after discharge losses, in kWh |
| `batteryGridImport` | Remaining demand purchased from the grid each hour, in kWh |
| `batteryGridExport` | Remaining surplus solar exported each hour, in kWh |

Each output contains 8,760 values. Annual imports and exports are calculated by summing the hourly grid flows. `annualBatteryNetImport` is annual imports minus annual exports. Monthly imports and exports are grouped using `house.Month` into 12 totals for Figure 3.

To compare battery sizes, change the capacity, power limit, and efficiency in the function call. The current 40 kWh setting replaces the previously planned 13.5 kWh scenario. The 10% reserve is set inside the function. Changing the time step would also require updating the power-to-energy conversion and dispatch logic.

## Data and Assumptions

Solar output comes from [PVWatts](https://pvwatts.nlr.gov/). Household usage is synthetic, with assumed daily and seasonal patterns scaled to 10,000 kWh/year.

| Parameter | Value |
| --- | --- |
| Solar capacity | 7 kW DC |
| Mounting | Fixed rooftop |
| Tilt / azimuth | 25° / 180° |
| Time step | 1 hour |
| Battery capacity | 40 kWh |
| Battery charge/discharge limit | 5 kW |
| Charging / discharging efficiency | 95% / 95% |
| Round-trip efficiency | 90.25% |
| Minimum / initial state of charge | 10% / 10% |

The household profile is not measured data. The battery model uses fixed capacity, power limits, and efficiencies; it does not include degradation, self-discharge, temperature effects, or outage/backup operation. Costs, tariffs, net-metering credits, and payback have not yet been calculated.

## Next Steps

- Add battery-specific energy-balance and state-of-charge checks, including conversion losses and changes in stored energy.
- Model electricity rates, net metering, savings, and payback.
- Compare solar and battery sizes, including the 13.5 kWh scenario.
- Evaluate the effect of initial and final battery state of charge on annual comparisons.

## Authors

- **Harmanjot Singh:** Battery modeling and simulation logic.
- **Matthew Cain:** Data processing and cost analysis.

Engineering students at Brookdale Community College.
