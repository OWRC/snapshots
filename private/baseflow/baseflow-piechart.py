
# collect all stations with good period of record, req. lat,lng,DA,<data>
# keep only locations that are within polygon
# determine annual average discharge in mm/yr
# plot to size of point=discharge

# import json
import numpy as np
import pandas as pd
# from shapely.geometry import Polygon, Point
from pyDrology.hydrographSeparation import estimateBaseflow, recessionCoef
from tqdm import tqdm
import matplotlib.pyplot as plt
# import matplotlib.dates as mdates
import base64
from io import BytesIO

dfLoc = pd.read_json('https://golang.oakridgeswater.ca/locsw')

# # filter by polygon
# with open("E:/Sync/@prj/MECP/lake_ontario_north_shore/shp/drain_bound.geojson") as f: features = json.load(f)["features"]
# coords = features[0]['geometry']['coordinates'][0][0] # taking only the first feature
# plgn = Polygon(coords)

# def point_in_polygon(row):
#     p = Point(row['LNG'],row['LAT'])
#     if plgn.contains(p): return True
#     return False

# dfLoc = dfLoc[dfLoc.apply(point_in_polygon,axis=1)]

# filter by quality (10yr POR, <25% missing, must have observations since 2000)
dfLoc = dfLoc[dfLoc['YRe'] > 1999]
dfLoc = dfLoc[dfLoc['CNT'] > 365.24*10*.75]
dfLoc = dfLoc[dfLoc['YRe'] - dfLoc['YRb'] > 9]



bfi = dict()
k = dict()
qm = dict()
html = dict()
month_names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'] 
pbar = tqdm(total=len(dfLoc))
for i, row in dfLoc.iterrows():
    iid = int(row['INT_ID']) 
    # if iid != 1311236873: continue
    pbar.update()
    pbar.set_description(str(iid))
    da = float(row['SW_DRAINAGE_AREA_KM2'])
    tem = pd.read_json('https://golang.oakridgeswater.ca/intgen/5/{}'.format(iid))
    tem = tem[tem['RDNC']==1001]
    if 'RDTC' not in tem: tem['RDTC'] = np.nan
    tem = tem.drop(['RDNC', 'RDTC', 'unit'], axis=1)
    tem.set_index('Date', inplace=True)
    if tem.empty: continue

    k[i] = recessionCoef(tem)
    
    tem['baseflow'] = estimateBaseflow(tem, da, k[i])

    m = tem.mean()
    bfi[i] = m['baseflow']/m['Val']
    qm [i] = m['Val']

    # plt.plot(tem.index, tem['Val'], 'b', alpha=0.75)
    # plt.plot(tem.index, tem['baseflow'], 'r', alpha=0.75)
    # plt.show()

    # collect monthly plot
    mtem = tem.groupby(tem.index.month).mean()
    fig, ax = plt.subplots(figsize=(3, 3))
    ax.plot(mtem.index, mtem['Val'], '#0069f2', alpha=0.75)
    ax.plot(mtem.index, mtem['baseflow'], '#ad6d00', alpha=0.75)
    plt.title(row['LOC_NAME'])
    plt.xticks(rotation=90)
    plt.ylabel('Discharge (cms)')
    ax.set_xticks(range(1,13))
    ax.set_xticklabels(month_names)
    ax.legend(['Total', 'Baseflow'])
    fig.tight_layout()
    # plt.show()
    # break

    # https://stackoverflow.com/questions/48717794/matplotlib-embed-figures-in-auto-generated-html
    tmpfile = BytesIO()
    fig.savefig(tmpfile, format='png')
    encoded = base64.b64encode(tmpfile.getvalue()).decode('utf-8')
    html[i] = '<img src=\'data:image/png;base64,{}\'>'.format(encoded) 
    # with open('test.html','w') as f:
    #     f.write(html[i])
    tmpfile.close()
    plt.close()   

pbar.close()

dfLoc['meanQ'] = dfLoc.index.map(qm)    
dfLoc['k'] = dfLoc.index.map(k)
dfLoc['BFI'] = dfLoc.index.map(bfi)
dfLoc['html'] = dfLoc.index.map(html)

print(dfLoc)
dfLoc.to_csv('snapshots-private/baseflow/baseflow-piechart-gauge-summary.csv', index=False)