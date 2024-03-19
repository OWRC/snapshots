
import pandas as pd
import sqlalchemy


dfloclst = pd.read_excel('dat/SampleData Loc from Britt.xlsx')
cnxn = sqlalchemy.create_engine("mssql+pyodbc://sqlyc-mm:dt82Wa35@cloca_oak_master")

# qry = """SELECT L.LOC_ID, INT_ID, LOC_NAME, LOC_NAME_ALT1, LAT, LONG, Z AS GRND_ELEV, FORMATION, SCREEN_TOP_DEPTH_M
#         FROM D_LOCATION AS L
#         LEFT JOIN (SELECT LOC_ID, LONG, LAT, Z FROM V_SYS_LOC_COORDS WHERE LAT IS NOT NULL ) AS C ON L.LOC_ID = C.LOC_ID
#         JOIN (
#             SELECT LOC_ID, INT_ID, FORMATION, SCREEN_TOP_DEPTH_M FROM W_GENERAL_SCREEN 
#         ) AS S ON L.LOC_ID = S.LOC_ID
#         WHERE L.LOC_ID IN {}""".format(tuple(dfloclst['loc id']))

qry = """SELECT L.LOC_ID, LOC_NAME, LOC_NAME_ALT1, LAT, LONG, Z AS GRND_ELEV
        FROM D_LOCATION AS L
        LEFT JOIN (SELECT LOC_ID, LONG, LAT, Z FROM V_SYS_LOC_COORDS WHERE LAT IS NOT NULL ) AS C ON L.LOC_ID = C.LOC_ID
        WHERE L.LOC_ID IN {}""".format(tuple(dfloclst['loc id']))

dfloc = pd.read_sql(qry, cnxn).merge(dfloclst, left_on='LOC_ID', right_on='loc id')
print(dfloc)
dfloc.to_csv('dat/locations.csv', index=False)