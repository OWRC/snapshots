
import pandas as pd
import sqlalchemy


dfloc = pd.read_csv('dat/locations.csv')
cnxn = sqlalchemy.create_engine("mssql+pyodbc://sql-webmm:fv62Aq31@cloca_oak_master")


qry = """SELECT LOC_ID, INT_ID, SAM_ID, NAME, 
        INTERVAL_NAME, ALTERNATE_INTERVAL_NAME, READING_GROUP_NAME, 
        INT_TYPE, PARAMETER, VALUE, UNIT, QUALIFIER, MDL, UNCERTAINTY, 
        SCREEN_GEOL_UNIT, SAMPLE_DATE, RD_NAME_CODE
        FROM V_GEN_LAB AS L
        JOIN R_READING_GROUP_CODE AS G ON G.READING_GROUP_CODE = L.GROUP_CODE
        WHERE PARAMETER IN ('Chloride','Sodium','Nitrate')
        AND UNIT LIKE 'mg/L'
        AND L.LOC_ID IN {}""".format(tuple(dfloc['LOC_ID']))

dfloc = pd.read_sql(qry, cnxn).merge(dfloc, on='LOC_ID')
dfloc['Year'] = dfloc['SAMPLE_DATE'].dt.year
dfloc['Month'] = dfloc['SAMPLE_DATE'].dt.month
dfloc['Date'] = dfloc['SAMPLE_DATE']
dfloc['Parameter'] = dfloc['PARAMETER']
dfloc['Value'] = dfloc['VALUE']
dfloc = dfloc.iloc[:,-8:]
print(dfloc)
dfloc.to_csv('dat/temporal.csv', index=False)
