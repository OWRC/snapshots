---
title: Wet/Dry Conditions Map
author: Oak Ridges Moraine Groundwater Program
output: html_document
---

The Wet/Dry Conditions Map provides an overview of recent hydrological conditions across the Oak Ridges Moraine Groundwater Program (ORMGP) study area. Conditions are classified as **Wet**, **Dry**, or **Normal** using recent precipitation totals and streamflow observations.

## 5-day Antecedent Precipitation

The cumulative precipitation over the preceding five days $(P_5)$ is used as an indicator of Antecedent Moisture Condition (AMC). Each precipitation monitoring station is classified according to three thresholds:

1. **Wet:** $P_5 > 27.5\text{ mm}$
2. **Dry:** $P_5 < 12.5\text{ mm}$
3. **Normal:** $12.5 \leq P_5 \leq 27.5\text{ mm}$

Stations with invalid precipitation values (negative values in the source dataset) are classified as **No Data**.

These classifications provide a simplified indication of recent wetness based on precipitation alone and do not directly measure soil moisture or groundwater conditions.

## Latest/Current Streamflow

For streamflow monitoring stations reporting data within the preceding seven days, the latest reported discharge $(Q_l)$ is compared against the statistical distribution of historical observations at the same gauge.

Stations are classified according to the following percentile thresholds:

1. **Wet:** $Q_l > Q_{P84}$
2. **Dry:** $Q_l < Q_{P16}$
3. **Normal:** $Q_{P16} \leq Q_l \leq Q_{P84}$

where $Q_{Pn}$ represents the $n^{\text{th}}$ percentile of historical streamflow observations at a station.

The $16^{\text{th}}$ and $84^{\text{th}}$ percentiles approximately correspond to one standard deviation below and above the mean for a normally distributed variable. However, streamflow distributions are generally skewed, so these classifications are based on empirical percentiles rather than assumptions of normality.

Unlike precipitation-based AMC, the streamflow classification reflects the relative magnitude of observed discharge compared with historical conditions at each station.

## Map Features

### Monitoring Stations

Precipitation and streamflow monitoring stations are displayed as separate map layers that can be independently enabled or disabled.

Selecting a station provides additional information:

- **Precipitation stations:** Station name, cumulative 5-day precipitation, observation date, and a link to the historical climate time series.
- **Streamflow stations:** Station name, latest discharge (m³/s), observation date, historical 16th and 84th percentile thresholds, and a link to the historical streamflow time series.

### Watershed Delineation and Selection

The map includes subwatershed boundaries that can be selected to explore contributing drainage areas.

Selecting a subwatershed highlights:

- **Selected subwatershed:** Blue
- **Upstream contributing subwatersheds:** Green
- **Downstream subwatersheds:** Dark red

Holding **Shift** allows multiple subwatersheds to be selected.

For the combined upstream contributing area, the map calculates and displays:

- Total drainage area (km²)
- Impervious surface coverage (%)
- Tree canopy coverage (%)
- Open water coverage (%)
- Wetland coverage (%)

Additional plots summarize the distribution of **land use** and **surficial geology** within the selected contributing area.

### Background Map Layers

The map provides several interchangeable background layers:

- ORMGP Basemap
- OpenStreetMap
- High-resolution Digital Elevation Model (DEM)
- Depth to Water Table
- Land Use
- Surficial Geology
- Optional hillshade and topographic overlay

Additional controls support distance and area measurements, map navigation, and fullscreen viewing.

## Interpretation and Limitations

The Wet/Dry classifications are intended as indicators of recent hydrological conditions rather than direct measures of flooding, drought severity, or groundwater availability.

Precipitation classifications use fixed thresholds applied consistently across stations, while streamflow classifications use station-specific historical percentiles. Consequently, the two indicators provide complementary but distinct information.

The classifications may differ because streamflow reflects not only recent precipitation but also antecedent storage, groundwater contributions, watershed characteristics, and other hydrological processes.

The map is intended to support regional hydrological assessment and comparison of current conditions, rather than replace detailed station-specific analysis.