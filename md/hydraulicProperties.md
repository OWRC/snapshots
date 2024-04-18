---
title: Hydraulic Properties
author: Oak Ridges Moraine Groundwater Program
output: html_document
---


The ORMGP is actively compiling hydrogeologic parameter estimates (e.g., porosity, specific capacity, storativity, transmissivity, hydraulic conductivity) for the various hydrostratigraphic units (Figure 1) into the program's database. To date, activities have focussed on collation of hydraulic conductivity (K) and specific capacity (SC) estimates. Further information on the use of water well specific capacity tests to estimate transmissivity and hydraulic conductivity can be found in Theis et al. (1963), Walton (1970), Bradbury and Rothschild (1985), Domenico and Schwartz (1990), Richard et al. (2016), and Priebe et al. (2018). For the ORMGP study area, the specific capacity estimates are being extended into estimates of transmissivity (T) and hydraulic conductivity (K) utilizing the methodology of Bradbury and Rothschild (1985). Further information on methodology is included in the [program's database manual](https://owrc.github.io/database-manual/Contents/TOC.html). Current estimates within the database are as follows:


1. K - estimates of hydraulic conductivity (K) from slug tests on piezometers/wells (Units = m/s). Locations with K estimates from slug test analysis are shown on Figure 2;
1. SPEC_CAP - specific capacity (pumping rate/maximum drawdown) estimates from data obtained during short-term pumping tests (<4 hours) conducted by well drillers following well installation (Units = L/minute/m). Locations with specific capacity (SC) estimates are shown on Figure 3. The cumulative probability plot of the data is shown on Figure 4;
1. TSC - Transmissivity (T) estimates from specific capacity (SC) estimates according to the methodology of Bradbury and Rothschild (1985) which allows for corrections for partial penetration of well screen and incorporates estimates of formation thickness (Units = m$^2$/s; Figure 4);
1. KSC - estimates of hydraulic conductivity (K) from specific capacity (SC) estimates utilizing methodology of Bradbury and Rothschild (1985). Cumulative probability plot of the data shown on Figure 5 (Units = m/s);
1. TSC_SCR - estimates of Transmissivity (T) from specific capacity (SC) estimates utilizing methodology of Bradbury and Rothschild (1985). The formation thickness is taken as the screen length (Units = m<sup>2</sup>/s; Figure 4); and
1. KSC_SCR - estimates of hydraulic conductivity (K) from specific capacity (SC) estimates (Figure 5) utilizing methodology of Bradbury and Rothschild (1985). The formation thickness is taken as the screen length (Units = m/s).

A summary of all the current hydraulic conductivity estimates within the ORMGP database is included in Figure 6 and Table 1.

![](hydraulicProperties-REG-hydrostrat-units.png)

*Figure 1: Summary of hydrostratigraphic units within the study area.*

## Interactive maps

> Please note that each map below takes around minute to load, so please be patient; there are >150,000 locations found with specific capacity being rendered.

`Hint: full-screen available in the top-left corner`



<iframe src="https://golang.oakridgeswater.ca/pages/hydraulicproperties-k.html" width="100%" height="400" scrolling="no" allowfullscreen></iframe>

*Figure 2: Map of hydraulic conductivity (K) estimates within the ORMGP information and analysis system. (be patient)*
<br><br>




<iframe src="https://golang.oakridgeswater.ca/pages/hydraulicproperties-se.html" width="100%" height="400" scrolling="no" allowfullscreen></iframe>

*Figure 3: Map of specific capacity (SC) estimates within the ORMGP information and analysis system. (be patient)*
<br><br>



## Cumulative Probability plots
`Hint: right-click to copy as image`

![](hydraulicProperties-ggplot-sc.png)

*Figure 4: Cumulative probability plot showing SPEC_CAP, TSC, and TSC_SCR (m²/s).*

<br>

![](hydraulicProperties-ggplot-k.png)

*Figure 5: Cumulative probability plot showing K, KSC and KSC_SCR (m/s).*



## Distributions
`Hint: right-click to copy as image`

![](hydraulicProperties-ggplot-k-violin.png)

*Figure 6: Distribution of hydraulic conductivity (m/s) by formation. Upper distribution (KSC_SCR) is hydraulic conductivity estimate from specific capacity utilizing the screen length as the aquifer thickness. The lower distribution (K) is hydraulic conductivity estimates from slug testing. Note that many of the KSC_SCR estimates in the figure apply to aquitard formations (e.g., Lower Newmarket Till). The ORMGP classifies screens according to formation by comparing screen elevation to the latest geologic model interpretation. KSC_SCR estimates for aquitard formations are treated as part of the program's QA/QC process which includes testing the 3D geologic unit interpretation. Specific capacity estimates are from water well testing at the time of well completion. While heterogeneities exist within study area aquitards, it is considered low probability that domestic water wells will be installed within aquitards. Areas with KSC_SCR estimates for aquitard formations are subject to further inspection and refinement of the 3D geologic/hydrostratigraphic unit interpretation where necessary.*

<br>

*Table 1: Summary distribution statistics of hydraulic conductivity (m/s).*

| Formation | estimate | n | mean | geomean | median |
|---|---:|---:|---:|---:|---:|
| Late Stage Glaciolacustrine-Glaciofluvial | K | 14 | 2.5E-05 | 1.2E-06 | 2.1E-06 |
|  | KSC_SCR | 3,417 | 1.1E-03 | 1.2E-04 | 1.5E-04 |
| Halton Till | K | 106 | 1.5E-05 | 2.4E-08 | 2.0E-08 |
|  | KSC_SCR | 1,446 | 1.2E-03 | 3.2E-04 | 3.7E-04 |
| Mackinaw/Oak Ridges | K | 152 | 1.7E-04 | 5.4E-06 | 6.7E-06 |
|  | KSC_SCR | 13,942 | 6.6E-04 | 1.6E-04 | 1.5E-04 |
| Channel - Silt | K | 18 | 9.5E-06 | 5.7E-07 | 1.1E-06 |
|  | KSC_SCR | 873 | 5.7E-04 | 1.3E-04 | 1.2E-04 |
| Channel - Sand | K | 10 | 4.7E-05 | 5.5E-06 | 1.9E-05 |
|  | KSC_SCR | 1,389 | 6.0E-04 | 1.2E-04 | 9.9E-05 |
| Upper Newmarket | K | 19 | 1.0E-05 | 3.3E-07 | 3.4E-07 |
|  | KSC_SCR | 13,734 | 7.5E-04 | 2.0E-04 | 1.9E-04 |
| Inter Newmarket Sediment | K | 21 | 4.0E-04 | 3.5E-06 | 1.0E-06 |
|  | KSC_SCR | 6,111 | 9.7E-04 | 2.1E-04 | 2.1E-04 |
| Lower Newmarket | K | 61 | 1.8E-04 | 4.4E-07 | 7.7E-07 |
|  | KSC_SCR | 11,657 | 8.8E-04 | 2.1E-04 | 2.2E-04 |
| Thorncliffe | K | 79 | 6.0E-04 | 1.8E-05 | 3.3E-05 |
|  | KSC_SCR | 10,254 | 6.4E-04 | 1.1E-04 | 1.0E-04 |
| Sunnybrook | K | 1 | 9.1E-07 | 9.1E-07 | 9.1E-07 |
|  | KSC_SCR | 6,971 | 4.6E-04 | 1.1E-04 | 1.1E-04 |
| Scarborough | K | 31 | 3.5E-04 | 2.4E-05 | 9.2E-05 |
|  | KSC_SCR | 6,928 | 6.9E-04 | 1.1E-04 | 1.2E-04 |
| Bedrock - Undifferentiated | K | 53 | 2.2E-05 | 7.1E-07 | 1.0E-06 |
|  | KSC_SCR | 77,114 | 5.3E-04 | 1.7E-05 | 1.7E-05 |



# References

Bradbury, K.R., and Rothschild, E.R. 1985. A computerized technique for estimating the hydraulic conductivity of aquifers from specific capacity data. Ground Water, 23(2), 240-246.

Copper, H.H., Jr., Bredehoeft, J.D., and Papadopulos, I.S. 1967. Response of a finite diameter well to an instantaneous charge of water. Water Resources Research, 3(1), 263-269.

Domenico, P.A., and Schwartz, F.W. 1990. Physical and Chemical Hydrogeology. John Wley & Sons, Inc., 824p.

Priebe, E.H., Neville, C.J., and Rudolph, D.L. 2018. Enhancing the spatial coverage of a regional high-quality hydraulic conductivity dataset with estimates made from domestic water-well specific-capacity tests. Hydrogeology Journal, 26, 395-405.

Richard, S.K., Chesnaux, R., Rouleau, A., and Coupe, R.H. 2015. Estimating the reliability of aquifer transmissivity obtained from specific capacity tests: examples from the Saguenay-Lac-Saint-Jean aquifers, Canada. Hydrological Sciences Journal, 61(1), 173-185.

Theis, C.V., Brown, R.H., and Meyer, R.R. 1963. Estimating the transmissivity of aquifers from the specific capacity of wells. In R. Bental (compiler), Methods of determining permeability, transmissivity, and drawdown. U.S. Geological Survey Water-Supply Paper 1536-I, p331-341.

Walton, W.C. 1970. Groundwater Resource Evaluation. McGraw-Hill Book Company. 664p.



<br>

*last commit 2024-04-15*
