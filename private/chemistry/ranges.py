

# ncfp = 'E:/Sync/@dev/pages_owrc/interpolants/interpolation/calc/rdpa-criticalTemperature/dat/202009301300_exportMSChourlyNetcdf.nc'
ncfp = "E:/Sync/@dev/pages_owrc/interpolants/interpolation/calc/rdpa-criticalTemperature/dat/202209271600_exportYCDBdaily.nc"

import netCDF4 as nc
import numpy as np
import pandas as pd

with nc.Dataset(ncfp) as ds:
    ds.set_auto_mask(False) # https://github.com/Unidata/netcdf4-python/issues/785
    # print(ds)
    # for v in ds.variables: print(v)

    tim = ds.variables['time']
    tims = nc.num2date(tim[:],tim.units).astype('datetime64[ns]')
    nt = len(tims)        

    lats = ds.variables['lat'][:]
    lngs = ds.variables['lon'][:]
    if 'z' in ds.variables: elev = ds.variables['z'][:]

    def getVar(vnam):
        print("  - "+vnam)
        v = ds.variables[vnam]
        v = ds.variables[vnam][:,:]
        v[v == -9999] = np.nan
        return v


    sids = np.array([int(i) for i in nc.chartostring(ds.variables['station_id'][:])])
    snms = np.array([str(i) for i in nc.chartostring(ds.variables['station_names'][:])])
    tc = getVar('mean_air_temperature')
    pt = getVar('total_precipitation')



tmsk = tims>np.datetime64('2011-09-30')
tc = tc[tmsk]
pt = pt[tmsk]

dftc = pd.DataFrame(tc, index=tims[tmsk])
dfpt = pd.DataFrame(pt, index=tims[tmsk])


def cleanNaN(df, thrsh=0.8):
    df = df.dropna(axis=1, how='all')
    df = df.dropna(axis=1, thresh=df.shape[0]*thrsh)
    return df
dftc = cleanNaN(dftc)
dfpt = cleanNaN(dfpt)

def addWY(df): 
    df['water_year'] = df.index.year.where(df.index.month < 10, df.index.year + 1)
    return df
dftc = addWY(dftc)
dfpt = addWY(dfpt)


npt = dfpt.groupby('water_year').agg('count')[1:-1]
spt = dfpt.groupby('water_year').agg('sum')[1:-1] # clip first and last years
mtp = dftc.groupby('water_year').agg('mean')[1:-1]
spt[npt<340] = np.nan
  

apn = spt.min(axis=0)
apx = spt.max(axis=0)
apm = spt.mean(axis=0)
atn = mtp.min(axis=0)
atx = mtp.max(axis=0)
atm = mtp.mean(axis=0)
asid = pd.DataFrame(sids)
ann = pd.DataFrame(snms)
alat = pd.DataFrame(lats)
alng = pd.DataFrame(lngs)



odf = pd.concat([asid, ann, alng, alat, apn, apm, apx, atn, atm, atx], axis=1,).dropna()
odf.columns= ['station_id','station_name', 'Longitude', 'Latitude','Pmin','Pmean','Pmax','Tmin','Tmean','Tmax']

print(odf)
odf.to_csv('ranges.csv')