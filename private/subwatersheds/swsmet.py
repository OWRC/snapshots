
import netCDF4 as nc
import numpy as np
import pandas as pd

ncfp = "E:/Sync/@dev/go/src/FEWS/precipCritTemperature/bins/202009301800-sixHourlyFinal.nc"


with nc.Dataset(ncfp) as ds:
    ds.set_auto_mask(False) # https://github.com/Unidata/netcdf4-python/issues/785
    # print(ds)
    for v in ds.variables: print(v)

    tim = ds.variables['time']
    tims = nc.num2date(tim[:],tim.units).astype('datetime64[ns]')
    nt = len(tims)

    def getVar(vnam):
        print("  - "+vnam)
        v = ds.variables[vnam][:,:]
        v[v == -9999] = np.nan
        return v

    sids = np.array([int(i) for i in nc.chartostring(ds.variables['station_id'][:])])

    pa = getVar('air_pressure').T
    ta = getVar('air_temperature').T
    rh = getVar('relative_humidity').T
    rf = getVar('rainfall_amount').T
    sf = getVar('snowfall_amount').T
    ws = getVar('wind_speed').T
    sm = getVar('surface_snow_melt_amount').T
    ea = getVar('water_potential_evaporation_amount').T
    

mpa = np.nanmean(pa, axis=1)/1000
mta = np.nanmean(ta, axis=1)
mrh = np.nanmean(rh, axis=1)
mws = np.nanmean(ws, axis=1)
mrf = np.nanmean(rf, axis=1)*4*365.24
msf = np.nanmean(sf, axis=1)*4*365.24
msm = np.nanmean(sm, axis=1)*4*365.24
mea = np.nanmean(ea, axis=1)*4*365.24

d = {'precipitation': mrf+msf, 
    'rainfall': mrf, 
    'snowfall': msf, 
    'snowmelt': msm,
    'air_pressure': mpa, 
    'air_temperature': mta, 
    'relative_humidity': mrh, 
    'wind_speed': mws, 
    'potential_evaporation': mea}

df = pd.DataFrame(data=d, index=sids)
df.index.name = 'sws_id'
print(df)

df.to_csv('snapshots-private/subwatersheds/swsmet.csv')
# wsf = ws.flatten()
# wsf = wsf[~np.isnan(wsf)]
# print(wsf)

print("COMPLETE!")