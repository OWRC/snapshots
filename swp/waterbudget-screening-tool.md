---
title: SWP Stress Assessment Screening Tool 
author: Oak Ridges Moraine Groundwater Program
output: html_document
---


> The Source Water Protection Stress Assessment Screening Tool provides an interactive way to explore potential water quantity stress under Ontario’s Source Water Protection Program. By bringing together current water-taking information, regional climate data, and surface-water monitoring within a single web-mapping environment, the tool helps users identify areas of potential concern, examine the factors contributing to stress, and highlight where further investigation may be warranted across participating watersheds.

## Introduction

Groundwater and surface-water resources must be managed to ensure they can continue to support ecological, municipal, agricultural, and industrial needs. Under Ontario's Source Water Protection program, water quantity stress assessments are used to identify subwatersheds where water demand may be approaching available supply and where more detailed investigation may be warranted.

The original Source Water Protection (SWP) stress assessments were completed between approximately 2008 and 2010 using the water-taking records, climate information, and hydrogeologic understanding available at the time. Since then, water-taking permits and demands have changed, climate datasets have improved, and regional groundwater and surface-water models have continued to evolve. These changes create a need for an updated, reproducible approach to screening water quantity stress.

The Source Water Protection Stress Assessment Screening Tool was developed by the [Oak Ridges Moraine Groundwater Program (ORMGP)](https://www.oakridgeswater.ca/), in collaboration with Source Protection Regions including the [South Georgian Bay Lake Simcoe Source Protection Region (SGBLS)](https://ourwatershed.ca/) and the [CTC Source Protection Region](https://www.ctcswp.ca/). The tool responds to a shared need to periodically revisit earlier Source Water Protection stress assessments using current datasets and regional modelling information.

Web-based tools bring together current water-taking information, regional climate data, groundwater and surface-water modelling, and water-budget information in a single interactive mapping environment. Users can explore potential groundwater and surface-water stress, compare screening results among subwatersheds, and investigate the factors contributing to those results.

The tool is intended as a screening and decision-support resource. It provides a consistent way to identify areas that may warrant additional review or more detailed water-budget assessment, rather than replacing the formal Source Water Protection stress-assessment process.


## The Stress Assessment Screening Tool

The screening tool provides an automated and reproducible framework for evaluating water quantity stress within defined source protection subwatersheds. It connects directly to ORMGP database allowing screening results to be updated as water-taking information, monitoring data, and model results change.

Users can examine groundwater and surface-water stress across participating areas, including the SGBLS and CTC Source Protection regions, and explore the individual water-budget components that contribute to the calculated stress.

A key advantage of the tool is the integration of information that would otherwise need to be assembled and evaluated separately. Water-taking records, climate data, groundwater and surface-water modelling results, and water-budget calculations are brought together within a common framework, providing a consistent basis for identifying areas where water stress may warrant further investigation.



## How Water Quantity Stress Is Calculated

The screening tool follows the water quantity stress assessment methodology established under Ontario's Source Water Protection framework and the Director's Technical Rules under the Ontario [*Clean Water Act, 2006*](https://www.ontario.ca/laws/statute/06c22).

Water quantity stress is evaluated by comparing water demand with the portion of the available water supply remaining after an environmental reserve has been accounted for. The resulting **Percent Water Demand** $(\text{PWD})$ is used to characterize the potential level of water quantity stress:

$$
\text{PWD} =
\frac{Q_\text{demand}}
{Q_\text{supply} - Q_\text{reserve}}
\times 100\%
$$

where $Q_\text{supply}$ represents the available water supply, $Q_\text{reserve}$ represents the portion of that supply reserved for environmental needs, and $Q_\text{demand}$ represents water use. Separate calculations are completed for groundwater and surface-water stress.

### Water Supply $(Q_\text{supply})$

**Groundwater supply** can include groundwater recharge and lateral groundwater flow and may be estimated using regional groundwater-flow models, such as those [maintained by the ORMGP](https://owrc.github.io/snapshots/md/numerical-model-custodianship-program.html).

For the purposes of this screening tool, groundwater supply is estimated from observed streamflow using [hydrograph separation analyses](https://owrc.github.io/snapshots/md/baseflow-piechart.html). Long-term baseflow provides an observation-based estimate of groundwater contributions to the surface-water system and allows groundwater supply to be screened consistently across watersheds using measured hydrologic data. This approach avoids making the screening results dependent on the availability or configuration of a particular regional groundwater flow model.

**Surface-water supply** is represented by monthly median streamflow, allowing seasonal changes in water availability to be incorporated into the assessment.

### Water Reserve $(Q_\text{reserve})$

A portion of the available water supply is reserved for environmental needs before water demand is considered.

For groundwater, the environmental reserve is set at **10% of annual groundwater supply**. For surface water, the reserve is based on monthly low-flow conditions, represented by the **10th percentile monthly discharge** $(Q_\text{p90})$, to account for the need to maintain streamflow and associated ecological functions during periods of reduced water availability.

<iframe src="https://golang.oakridgeswater.ca/pages/swp/streamflow.html" width="100%" height="400" scrolling="no" allowfullscreen></iframe>

**Locations of recent stream gauges and estimated recharge rates (mm/year). Point size represents gauge catchment area, while colour indicates relative differences in estimated recharge. Click a gauge point or watershed polygon to view a summary of $Q_\text{supply}$ and $Q_\text{reserve}$. The method used to generate the map is [described below](#derivation-and-spatial-infill-of-mean-annual-runoff).**

<br>

### Water Demand $(Q_\text{demand})$

Water demand is calculated using active Ministry of the Environment, Conservation and Parks (MECP) **Permits to Take Water (PTTW)**.

Where recent reported actual water-taking information is available, it can be used to characterize current demand. Where recent actual-taking records are unavailable, the **maximum permitted taking volume** is used as a conservative estimate of potential demand. This approach reduces the likelihood that potential water use will be underestimated where reporting is incomplete and provides a precautionary basis for screening areas that may warrant further investigation. Locations of active Permits to Take Water (PTTWs), as of October 2025, maintained in the ORMGP database <a href="https://golang.oakridgeswater.ca/pages/swp/pttw.html" target="_blank" rel="noopener noreferrer">**can be viewed here**</a>. Currently, of the 7680 known permits, only 520 (7%) have been co-located with a well.


<!-- <iframe src="https://golang.oakridgeswater.ca/pages/swp/pttw.html" width="100%" height="300" scrolling="no" allowfullscreen></iframe>

**Locations of active (as of October 2025) permits to take water (PTTW) maintained in the ORMGP database. Currently, of the 7680 permits shown, only 520 (7%) have been co-located with a well.** -->

<br>


### Stress Assessment

Following Ontario’s Source Protection guidance, water quantity stress is classified using Percent Water Demand (PWD). Stress is considered **significant** where PWD exceeds 50%, **moderate** where PWD exceeds 25%, and **low** where PWD is less than 25%. Results shown here reflect current water-taking conditions and the applied [consumptive use factors](#consumptive-use-factors).

<iframe src="https://golang.oakridgeswater.ca/pages/swp/pwd.html" width="100%" height="400" scrolling="no" allowfullscreen></iframe>

**Current water quantity stress conditions. Click a water-taking permit (point) or Source Water Protection watershed to view a breakdown of the stress calculation.**

<br>


# Calculations

## Derivation and Spatial Infill of Mean Annual Runoff

Mean annual runoff and baseflow are estimated across the 10 km² basin network using available streamflow-gauge statistics together with the modelled drainage topology.

For each gauge, mean discharge is normalized by the reported drainage area and converted to an equivalent annual runoff depth:

$$
Q_r = \frac{\overline{Q}}{A} \times 86.4 \times 365.24
$$

where $Q_r$ is mean annual runoff (mm/year), $\overline{Q}$ is mean discharge (m³/s), and $A$ is gauge drainage area (km²). Gauge records producing calculated runoff values greater than 1,000 mm/year are excluded from further processing as potential outliers.

Mean annual baseflow is then estimated from the calculated runoff and the gauge-specific baseflow index (`BFI`):

$$
Q_b = Q_r \times BFI
$$

where $Q_b$ is mean annual baseflow expressed as an equivalent depth (mm/year).

### Assignment Through the Drainage Network

The runoff and baseflow estimates associated with each gauge are assigned to the basin containing the gauge and to all basins located upstream of that gauge within the modelled drainage network. This assumes that the specific runoff and baseflow observed at the gauge are representative of conditions throughout its contributing drainage area.

A basin may fall within the contributing area of more than one downstream gauge and therefore receive multiple independent gauge-derived estimates. Where this occurs, the available runoff and baseflow estimates are averaged to obtain a single value for the basin.

Following this upstream assignment, portions of the drainage network may remain without an estimate. A second, downstream infill procedure is therefore applied programmatically. Beginning with headwater basins and progressing downstream through the network, an unassigned downstream basin inherits the runoff and baseflow estimates of its immediately upstream basin. This extends gauge-derived estimates through downstream portions of the drainage network that are not otherwise constrained by a gauge.

### Final Spatial Infill

Some basins may remain unassigned following the drainage-network-based processing. These remaining gaps are infilled spatially in QGIS using nearby basins with valid estimates.

Basins that already contain runoff and baseflow values are retained unchanged. For each unassigned basin, the five nearest basins containing valid estimates are identified, and the arithmetic mean of those five values is assigned to the unassigned basin.


<!-- ```qgis
CASE
WHEN "meanBF" > 0 THEN
    "meanBF"
ELSE
    array_mean(
        overlay_nearest(
            layer := 'PDEM-South-D2013-OWRC25-60-HC-sws10',
            expression := "meanBF",
            filter := "meanBF" > 0,
            limit := 5
        )
    )
END
``` -->

<!-- ```qgis
CASE
WHEN "meanQ" > 0 THEN
    "meanQ"
ELSE
    array_mean(
        overlay_nearest(
            layer := '04-PDEM-South-D2013-OWRC25-60-HC-runoff',
            expression := "meanQ",
            filter := "meanQ" > 0,
            limit := 5
        )
    )
END
``` -->

The overall procedure therefore gives priority to hydrologic connectivity. Gauge observations are first propagated throughout their contributing upstream drainage areas, overlapping gauge estimates are averaged, and remaining downstream gaps are filled using the drainage topology. Only basins that remain unassigned after these hydrologically based procedures are infilled spatially using the mean of the five nearest basins with valid estimates.

### Limitations

The approach assumes that gauge-derived specific runoff and baseflow are reasonably representative of the contributing drainage area and that hydrograph separation provides a suitable estimate of groundwater contributions to streamflow.

Flow regulation, reservoirs, water diversions, urban stormwater management, and other alterations to the natural hydrograph can affect both measured streamflow and the results of hydrograph-separation analyses. Consequently, baseflow-derived estimates of groundwater supply may be less reliable in watersheds where runoff is substantially regulated or managed.

Where these effects are significant, or where cross-boundary groundwater flow is expected to be an important component of the water budget, estimates derived from a calibrated regional groundwater-flow model may provide a more appropriate basis for detailed assessment.


## Consumptive Use Factors

Consumptive use factors applied in the screening assessment are summarized below.

These factors are used to estimate the portion of a permitted water taking that is not returned to the local water system.

<div id="consumptive-use-table">
  <p>Loading consumptive use factors...</p>
</div>

<script>
fetch("data/consumptive_use_factor.csv")
  .then(response => {
    if (!response.ok) {
      throw new Error(`HTTP error ${response.status}`);
    }
    return response.text();
  })
  .then(csv => {
    const lines = csv.trim().split(/\r?\n/);

    function parseCSVLine(line) {
      const values = [];
      let value = "";
      let insideQuotes = false;

      for (let i = 0; i < line.length; i++) {
        const char = line[i];

        if (char === '"') {
          if (insideQuotes && line[i + 1] === '"') {
            value += '"';
            i++;
          } else {
            insideQuotes = !insideQuotes;
          }
        } else if (char === "," && !insideQuotes) {
          values.push(value.trim());
          value = "";
        } else {
          value += char;
        }
      }

      values.push(value.trim());
      return values;
    }

    const rows = lines.map(parseCSVLine);

    const table = document.createElement("table");
    table.style.width = "100%";
    table.style.borderCollapse = "collapse";

    const thead = document.createElement("thead");
    const headerRow = document.createElement("tr");

    rows[0].forEach(header => {
      const th = document.createElement("th");
      th.textContent = header;
      th.style.textAlign = "left";
      th.style.padding = "6px 10px";
      th.style.borderBottom = "2px solid #888";
      headerRow.appendChild(th);
    });

    thead.appendChild(headerRow);
    table.appendChild(thead);

    const tbody = document.createElement("tbody");

    rows.slice(1).forEach(row => {
      const tr = document.createElement("tr");

      row.forEach(value => {
        const td = document.createElement("td");
        td.textContent = value;
        td.style.padding = "6px 10px";
        td.style.borderBottom = "1px solid #ddd";
        tr.appendChild(td);
      });

      tbody.appendChild(tr);
    });

    table.appendChild(tbody);

    const container = document.getElementById("consumptive-use-table");
    container.innerHTML = "";
    container.appendChild(table);
  })
  .catch(error => {
    document.getElementById("consumptive-use-table").innerHTML =
      `<p><em>Consumptive use factors could not be loaded: ${error.message}</em></p>`;
    console.error(error);
  });
</script>

<br>

<!-- [Download the consumptive use factor CSV](https://data.oakridgeswater.ca/supplemental/SWP-Water-budget-screening/consumptive_use_factor.csv) -->
