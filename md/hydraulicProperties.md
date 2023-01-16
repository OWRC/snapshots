---
title: Hydraulic Properties
author: Oak Ridges Moraine Groundwater Program
output: html_document
---

> **Please note that this page takes a minute to load, there are >150,000 locations found with specific capacity being rendered.**

&nbsp;&nbsp;The ORMGP is actively compiling hydrogeologic parameter estimates (e.g., porosity, specific capacity, storativity, transmissivity, hydraulic conductivity) into the program's database. To date, activities have focussed on collation of hydraulic conductivity (K) and specific capacity (SC) estimates. The specific capacity estimates are being extended into estimates of transmissivity (T) and hydraulic conductivity (K) utilizing the methodology of Bradbury and Rothschild (1985). Further information of methodology is included in the program's database manual (ADD LINK TO DB MANUAL).

<ol>
  <li>K_MS - estimates of hydraulic conductivity (K) from slug tests on piezometers/wells (Units = m/s). Locations with K estimates from slug test analysis are shown on Figure 1;</li>
  <li>SPEC_CAP_LPMM - specific capacity (pumping rate/maximum drawdown) estimates from data obtained during short-term pumping tests (<4 hours) conducted by well drillers following well installation (Units = L/minute/m). Locations with specific capacity (SC) estimates are shown on Figure 2. The cumulative probability plot of the data is shown on Figure 3;</li>
  <li>TSC_M2S - Transmissivity (T) estimates from specific capacity (SC) estimates according to the methodology of Bradbury and Rothschild (1985) which allows for corrections for partial penetration of well screen and incorporates estimates of formation thickness (Units = m^2^/s; Figure 3);</li>
  <li>KSC_MS - estimates of hydraulic conductivity (K) from specific capacity (SC) estimates utilizing methodology of Bradbury and Rothschild (1985). Cumulative probability plot of the data shown on Figure 4 (Units = m/s);</li>
  <li>TSC_SCR_M2S - estimates of Transmissivity (T) from specific capacity (SC) estimates utilizing methodology of Bradbury and Rothschild (1985). The formation thickness is taken as the screen length (Units = m^2^/s; Figure 3); and</li>
  <li>KSC_SCR_MS - estimates of hydraulic conductivity (K) from specific capacity (SC) estimates (Figure 4) utilizing methodology of Bradbury and Rothschild (1985). The formation thickness is taken as the screen length (Units = m/s).</li>
</ol>

MASON - can we insert a map of K_MS locations from the W_GENERAL_SCREEN table. This will be similar to Figure 2 below for SC please.

`Full-screen available in the top-left corner`

<iframe src="https://golang.oakridgeswater.ca/pages/hydraulicproperties.html" width="100%" height="400" scrolling="no" allowfullscreen></iframe>

*be patient*

Figure 2: Map of specific capacity (SC) estimates within the ORMGP information and analysis system.

Mason - can we please prepare a Figure 3 here with data from W_GENERAL_SCREEN - cumulative probability plot showing SPEC_CAP_LPMM (but units translated from L/min/m to m2/s), TSC_M2S, and TSC_SCR_M2S. Ylog scale, X cumulative probability scale, n=count in legend for the 3 datasets plotted.

Mason - can we please prepare a Figure 4 here with data from W_GENERAL_SCREEN - cumulative probability plot showing K_MS, KSC_MS and KSC_SCR_MS. Y log scale, X cumulative probability scale, n=count in legend for the 3 datasets plotted.
