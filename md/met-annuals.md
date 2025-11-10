---
title: Climate summary, a regional look
author: Oak Ridges Moraine Groundwater Program
output: html_document
---

This snapshot provides a regional overview of the meteorological time-series data held at the ORMGP, allowing for long-term (past decade) averages of temperature and precipitation at stations across the study area. The temperature and precipitation data held at the ORMGP are [updated on a nightly basis from multiple sources](https://owrc.github.io/interpolants/sources/webscraping.html). For the ORMGP study area, the values presented are inspired by the last comprehensive overview of Ontario's climate data, which was prepared in [1980 by the then Ministry of Natural Resources (Brown, 1980)](https://golang.oakridgeswater.ca/pages/pdf/1984_MNR_Water_Quantity_Resources_Ontario.pdf).  


### Data processing
In the maps below, climate stations having recorded precipitation or temperature data over the past 10 years are shown. Locations circled in red are locations that fail to meet the WMO 3--5 rule more than 15% of the reported months. The WMO 3--5 rule: months that have more than 5 days missing or more than 3 consecutive days missing are deemed incomplete.

Precipitation is summed and air temperature is averaged for every water year (Oct-Sept).  Minimum, mean, and maximum values of these annual sums/averages are posted once a station is `clicked`.

<br>

## Precipitation

Active climate stations are colour coded based on the ten year average precipitation. Stations with the greatest annual average precipitation, (of greater than 1,100 mm/yr) are found inland from Georgian Bay and Lake Ontario in the north parts of the ORMGP study area.  Stations with the lowest precipitation, (of around 700 mm/yr) are generally found along the Lake Ontario shoreline.

`click on any circle to reveal station summaries. Full-screen available in the top-left corner`

<iframe src="https://golang.oakridgeswater.ca/pages/met-annuals-precip.html" width="100%" height="550" scrolling="no" allowfullscreen></iframe>

<br>

## Temperature

Active climate stations colour coded based on the ten year average temperature. Stations with the highest annual temperature, of around 10°C, are found along the Lake Ontario shoreline in the heavily urbanized cities or Toronto, Hamilton and Mississauga. In the northerly parts of the ORMGP study area, inland from Georgian Bay, are the stations with the lowest average temperature of between 5°C and 6°C.  The moderating influence of the Great Lakes can be observed by comparing the average temperatures at stations closer to Lake Huron and Lake Ontario to stations further inland from the lakes.

`click on any circle to reveal station summaries. Full-screen available in the top-left corner`

<iframe src="https://golang.oakridgeswater.ca/pages/met-annuals-temperature.html" width="100%" height="550" scrolling="no" allowfullscreen></iframe>


## Interpolated data

For areas where stations are not available or for stations with incomplete data, the ORMGP hosts a [near real-time climate data service](https://owrc.github.io/interpolants/sources/climate-data-service.html). 


<iframe src="https://golang.oakridgeswater.ca/pages/swsmet.html" width="100%" height="550" scrolling="no" allowfullscreen></iframe>
