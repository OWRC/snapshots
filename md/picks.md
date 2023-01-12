---
title: Geological Picks
author: Oak Ridges Moraine Groundwater Program
output: html_document
---


A geological pick, in the context of the ORMGP, is an x/y/z assignment, usually at a well or borehole location, that represents the interpreted top of a regionally extensive geological unit.  For the most part the picks in the database have been made on dynamic cross-sections that allow for the different intersected layers in a borehole to be readily displayed.  Picks are made on those layers that are interpreted to reflect the regional geological surfaces of interest (e.g. Halton Till, Oak Ridges Moraine, etc.), and therefore more minor sand lenses or other local units might not be reflected in the geological picks. These geologic picks are stored in the ‘PICKS’ table in the database.

In addition to picks at wells, there are additional imported or synthetic picks that are also stored in the Picks table, these include:
- Outcrops - Picks generated through geological mapping at ground surface, whereby geological boundaries and areas of mapped regional layers have been assigned x/y/z values based on the ground elevation;
- Polylines - Picks generated through polylines that were drawn on cross section to help in delineating interpreted geology layer pinch outs (e.g. where channelization has been interpreted to have eroded through pre-existing layers). x/y/z values assigned at every vertex point along each polyline; 
- Bedrock - Automated bedrock picks at wells, where x/y/z values are assigned at a well at the elevation of the uppermost bedrock layer (e.g. limestone, shale, bedrock, etc.) encountered.

The ‘PICKS’ and the ‘PICKS_EXTERNAL’ tables in the database hold the picks utilized for 3D geologic surface construction. Each type of pick can be incorporated or omitted from the interpolation of the geological surfaces. 



<br>

*please be patient for the below map to load...*

<iframe src="https://golang.oakridgeswater.ca/pages/ycdb-picks.html" width="100%" height="800" scrolling="no" allowfullscreen></iframe>
<br>

-