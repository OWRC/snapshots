---
title: OWES Hydrologic Screening Tool
author: Oak Ridges Moraine Groundwater Program
output: html_document
---


## Purpose, Method and Treatment of Wetland Groups

### Purpose and Context

The Ontario Wetland Evaluation System (OWES) provides the provincial framework for evaluating wetland functions and determining wetland significance. The evaluation considers four major components: Biological, Social, Hydrological and Special Features and relies on a combination of field observations, existing information, mapping and professional judgement. OWES evaluations must ultimately be undertaken and attested to by a trained wetland evaluator.

The **ORMGP OWES Hydrologic Screening Tool** was developed to automate the spatially intensive calculations associated with the **flood attenuation portion of the OWES Hydrological Component**. The intent is not to replace an OWES evaluation or the judgement of a qualified evaluator. Rather, the tool provides a rapid, consistent and reproducible means of assembling the watershed information needed to support the OWES calculation and to screen large numbers of wetlands across the Oak Ridges Moraine Groundwater Program (ORMGP) jurisdiction.

Under OWES, flood attenuation is evaluated using three principal spatial characteristics: **the area of the wetland, the area of its upstream catchment, and the area of other detention features within that catchment**. These relationships are used to assess how effectively a wetland can reduce downstream flood peaks. The ORMGP tool automates the determination of these spatial inputs and applies the OWES scoring calculations. The presentation developed for the tool identifies the required inputs as wetland area, wetland catchment area, other detention areas within the catchment, and connectivity or proximity to major waterbodies.



### How the Tool Works

A key capability underlying the application is automated drainage-area delineation. The [ORMGP's terrain-processing workflow](https://owrc.github.io/interpolants/interpolation/overland.html) uses a digital elevation model to establish flow directions and drainage connectivity. Depression filling and treatment of flat areas are applied before flow paths are calculated, allowing a catchment to be delineated automatically to a selected location.

For wetlands, the original point-based drainage-area tool was modified so that a user selecting a location within a mapped wetland does not simply receive the area draining to that individual point. Instead, the application identifies the wetland and delineates the drainage area contributing to the wetland as a whole. Within that catchment, the tool identifies other wetlands and waterbodies that may provide upstream detention and calculates their areas.

This directly reflects the OWES flood-attenuation methodology. OWES requires evaluators to consider **all detention areas in the basin**, not just features directly connected to an inflowing stream. Detention areas can include other wetlands (including isolated wetlands) as well as lakes, large rivers, reservoirs, ponds and flooded pits or quarries. The OWES Wetland Evaluation Data and Scoring Record then combines wetland area, catchment area and other detention area to calculate the **Upstream Detention Factor** and **Wetland Attenuation Factor**, which together determine the flood attenuation score.

The screening application currently operates across approximately **126,700 mapped wetlands**, uses provincial wetland mapping by default, and can accommodate alternative or more detailed wetland mapping supplied by ORMGP partners. Results are available through an interactive Shiny/Leaflet application (see above) and can also be accessed programmatically through a REST API.

### Treatment of Wetland Groups

An important implementation consideration is determining **what constitutes the wetland being evaluated**, particularly where mapped wetland polygons are divided by roads, railways or other narrow non-wetland features.

OWES clearly recognizes that a wetland does not necessarily have to consist of a single homogeneous vegetation polygon. A *wetland unit* is defined as **“a single wetland or a contiguous group of wetland communities,”** surrounded by non-wetland areas. The manual also explicitly recognizes situations in which **closely grouped wetlands function together as one**. Examples include clusters of small wetland ponds separated by small upland pockets and wetlands along a lake or river separated by short distances. In these circumstances, OWES directs that the features be evaluated as one wetland rather than as separate individual wetlands.

OWES boundary mapping also distinguishes between the **outer boundary of the wetland** and features occurring within that boundary. The Wetland Boundary Map is expected to show all outer wetland boundaries as well as features such as **roads, rivers and streams occurring within or adjacent to the wetland**. Wetland boundaries themselves are primarily determined from the presence and relative abundance of wetland vegetation, supported where necessary by substrates, topography and other evidence.

On this basis, the screening tool currently **groups wetland polygons that are interrupted by road segments where they appear to represent parts of the same functional wetland**. This treatment is important because arbitrarily dividing a wetland at a road can substantially alter its calculated area, catchment and relationship to upstream detention areas, and therefore change its calculated flood-attenuation score. The current implementation is documented in the tool presentation as grouping wetlands broken by road segments, while recognizing that whether these features should remain separate is an important evaluation question.

The working assumption is that where wetland vegetation and wetland conditions continue on both sides of a road or railway, the portions will commonly remain **hydrologically connected**, for example through culverts, surface drainage or groundwater, and will generally occupy the same local catchment. Consequently, a narrow transportation corridor should not automatically be assumed to represent a functional hydrologic separation.

Importantly, **OWES does not establish a universal rule that every pair of wetlands separated by a road or railway must be combined**. The automated grouping used by the tool should therefore be regarded as a screening assumption rather than a replacement for evaluator judgement. Where field observations, vegetation mapping, hydraulic structures, topography or other information indicate that two areas function independently, the evaluator should be able to treat them as separate wetland units.

### Intended Use

The ORMGP OWES Hydrologic Screening Tool is therefore best viewed as a **decision-support and pre-screening application**. It automates calculations that would otherwise require substantial GIS processing, applies those calculations consistently across a large regional wetland inventory, and provides evaluators with transparent information on wetland area, contributing catchment, upstream detention and hydrologic context. It can substantially reduce the effort required to undertake the hydrologic portion of an OWES assessment while leaving wetland delineation, interpretation of unusual circumstances, verification of hydrologic connectivity and the final OWES determination with the qualified wetland evaluator.

