
import pandas as pd
import sqlalchemy
import shapefile
from shapely.geometry import Point, Polygon


# dfloclst = pd.read_excel('xr/locations.xlsx')
# dicloc = dict(zip(dfloclst['ORMGP Loc ID'],dfloclst['Well'])) #.to_dict()
cnxn = sqlalchemy.create_engine("mssql+pyodbc://sql-webmm:fv62Aq31@cloca_oak_master")
muni = shapefile.Reader("E:/Sync/@gis/Boundaries/municipal/MUNICIPAL_BOUNDARY_LOWER_AND_SINGLE_TIER-ORMGP.shp")



# collect polygons
plys = list()
shps = muni.shapes()
recs = muni.records(fields=['NAME','UPPER_TIER'])
for i in range(muni.numShapes): 
     s = shps[i]
     r = recs[i]
     plys.append((s.bbox,Polygon(s.points),r.UPPER_TIER.capitalize(),r.NAME.capitalize()))

def pnp(pnt):
    for p in plys:
        if pnt.within(p[1]): return (p[2],p[3])
    return (None,None)

def vpnp(row):
    row['Upp_Muni'], row['Muni'] = pnp(Point(row['LONG'],row['LAT']))
    return row

def crenam(row): 
    # if row['LOC_ID'] in dicloc: 
    #     row['Well'] = dicloc[row['LOC_ID']]
    # elif row['LOC_NAME'].isnumeric():
    if row['LOC_NAME'].isnumeric():
        row['Well'] = row['LOC_NAME_ALT1']
    else:
        row['Well'] = row['LOC_NAME']
    return row


qry = """SELECT L.LOC_ID, LOC_NAME, LOC_NAME_ALT1, LOC_NAME_ALT2, LAT, LONG, Z AS GRND_ELEV, PURPOSE_SECONDARY_CODE
        FROM D_LOCATION AS L
        LEFT JOIN (SELECT LOC_ID, LONG, LAT, Z FROM V_SYS_LOC_COORDS WHERE LAT IS NOT NULL ) AS C ON L.LOC_ID = C.LOC_ID
        LEFT JOIN V_SYS_LOC_PURPOSE AS P ON P.LOC_ID=L.LOC_ID
        WHERE LOC_TYPE_CODE = 1
        AND PURPOSE_PRIMARY_CODE = 10
        --AND PURPOSE_SECONDARY_CODE IN (22,59)
        AND PURPOSE_SECONDARY_CODE = 22
        AND LAT IS NOT NULL
        AND LONG < -76.558"""
# "LONG < -76.558" is to exclude ottawa


dfloc = pd.read_sql(qry, cnxn).apply(vpnp, axis=1).apply(crenam, axis=1)
print(dfloc)
dfloc.to_csv('dat/locations.csv', index=False)




# # OLD
# dfloclst = pd.read_excel('xr/SampleData Loc from Britt.xlsx')
# cnxn = sqlalchemy.create_engine("mssql+pyodbc://sql-webmm:fv62Aq31@cloca_oak_master")
# muni = shapefile.Reader("E:/Sync/@gis/Boundaries/municipal/MUNICIPAL_BOUNDARY_LOWER_AND_SINGLE_TIER-ORMGP.shp")


# # collect polygons
# plys = list()
# shps = muni.shapes()
# recs = muni.records(fields=['NAME','UPPER_TIER'])
# for i in range(muni.numShapes): 
#      s = shps[i]
#      r = recs[i]
#      plys.append((s.bbox,Polygon(s.points),r.UPPER_TIER.capitalize(),r.NAME.capitalize()))

# def pnp(pnt):
#     for p in plys:
#         if pnt.within(p[1]):
#             print(p)
#             return (p[2],p[3])

# def vpnp(row):
#     row['Upp_Muni'], row['Muni'] = pnp(Point(row['LONG'],row['LAT']))
#     return row

# qry = """SELECT L.LOC_ID, LOC_NAME, LOC_NAME_ALT1, LOC_NAME_ALT2, LAT, LONG, Z AS GRND_ELEV
#         FROM D_LOCATION AS L
#         LEFT JOIN (SELECT LOC_ID, LONG, LAT, Z FROM V_SYS_LOC_COORDS WHERE LAT IS NOT NULL ) AS C ON L.LOC_ID = C.LOC_ID
#         WHERE L.LOC_ID IN {}""".format(tuple(dfloclst['loc id']))

# dfloc = pd.read_sql(qry, cnxn).merge(dfloclst, left_on='LOC_ID', right_on='loc id').apply(vpnp, axis=1)
# print(dfloc)
# dfloc.to_csv('dat/locations.csv', index=False)