
import os
import numpy as np
import pandas as pd
from pygam import LinearGAM
import pymannkendall as mk
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
from datetime import datetime, timedelta
from pymmio import files



import sqlalchemy
cnxn = sqlalchemy.create_engine("mssql+pyodbc://sql-webmm:fv62Aq31@cloca_oak_master")

rootdir = 'E:/Sync/@dev/pages_owrc/snapshots-private/gwvar/'


# dfLoc = pd.read_json('https://golang.oakridgeswater.ca/locgw') # locations with >34 values, with coordinates
qloc = """SELECT L.LOC_ID, INT_ID, LOC_NAME, LOC_NAME_ALT1, SCREEN_NAME, LAT, LONG, Z, FORMATION, SCREEN_DIAMETER_CM, SCREEN_TOP_DEPTH_M, WL_AVG_MASL, WL_AVG_TOTAL_NUM, WL_START_DATE_MDY, WL_END_DATE_MDY
			FROM D_LOCATION AS L
			INNER JOIN (
				SELECT LOC_ID, INT_ID, FORMATION, SCREEN_NAME, SCREEN_DIAMETER_CM, SCREEN_TOP_DEPTH_M, WL_AVG_MASL, WL_AVG_TOTAL_NUM, WL_START_DATE_MDY, WL_END_DATE_MDY
				FROM W_GENERAL_SCREEN 
                WHERE WL_AVG_TOTAL_NUM > 34
			) AS S ON L.LOC_ID = S.LOC_ID
			INNER JOIN (
				SELECT LOC_ID, LONG, LAT, Z
				FROM V_SYS_LOC_COORDS
				WHERE LAT IS NOT NULL
			) AS C ON L.LOC_ID = C.LOC_ID"""
dfLoc = pd.read_sql(qloc, cnxn).drop_duplicates()
# print(dfLoc)
lname = dict(zip(dfLoc.INT_ID,dfLoc.LOC_NAME))
sname = dict(zip(dfLoc.INT_ID,dfLoc.SCREEN_NAME))
depths = dict(zip(dfLoc.INT_ID,dfLoc.SCREEN_TOP_DEPTH_M))



# #############################################
# ### STEP 1: query database for temporal data
# dfLoc.to_csv(rootdir+'gwvar-summary-qloc.csv', index=False)
# files.mkDir('pkl')
# done = set(files.dirList('pkl',"pkl"))
# for i, row in dfLoc.iterrows():
#     iid = int(row['INT_ID']) 
#     if os.path.isdir(rootdir+'pkl/{}.pkl'.format(iid)): continue
#     print("{} qry".format(iid), end=" ", flush=True)

#     # tem = pd.read_json('https://golang.oakridgeswater.ca/intgen/2/{}'.format(iid)) # ordered by date   
#     # tem = tem[tem['RDNC']==629] # Water Level - Logger (Compensated & Corrected-masl)
#     # if 'RDTC' not in tem: tem['RDTC'] = np.nan 
#     # tem = tem.drop(['RDNC', 'RDTC', 'unit'], axis=1).set_index('Date')
#     q = """SELECT SYS_RECORD_ID, RD_DATE as Date, RD_VALUE as Val
#             FROM OAK_20160831_MASTER.dbo.D_INTERVAL_TEMPORAL_{} 
#             WHERE RD_VALUE IS NOT NULL 
#             AND RD_NAME_CODE = {} 
#             AND REC_STATUS_CODE < 100
#             AND INT_ID = {} 
#             ORDER BY RD_DATE""".format(2,629,iid)
#     tem = pd.read_sql(q, cnxn).set_index('Date')

#     if len(tem.index) < 34:
#         print("< 34")
#         continue
    
#     # remove outliers
#     print('rm.out', end=" ")
#     p25 = tem['Val'].quantile(0.25)
#     p75 = tem['Val'].quantile(0.75)
#     iqr = p75-p25
#     upper_limit = p75 + 1.5 * iqr
#     lower_limit = p25 - 1.5 * iqr
#     recs = set(tem['SYS_RECORD_ID'].values)
#     tem = tem[tem['Val'] < upper_limit]
#     tem = tem[tem['Val'] > lower_limit]
#     recs -= set(tem['SYS_RECORD_ID'].values) # remaining elements were deemed outlier

#     if len(recs)>0: 
#         with open(rootdir+'pkl/gwvar-summary.py-outliers.txt', "a") as myfile: 
#             myfile.write("{},{}\n".format(iid,recs))

#     # resample to daily  
#     print('rsmpl', end=" ")  
#     tem = tem.resample('D').mean().dropna()    

#     print("saving pickle..")
#     tem.to_pickle(rootdir+'pkl/{}.pkl'.format(iid))
    




############################
### STEP 2: perform stats

# create collectors
nval = dict()
ampli = dict()
MKt = dict()
MKp = dict()

# create a PdfPages object
pdf = PdfPages(rootdir+'gwvar-summary.py.pdf')
fig = plt.figure()

dtMK = datetime.now() - timedelta(days = 10*365.24)
for fp in files.dirList(rootdir+'pkl','.pkl'):
    iid = int(files.getFileName(fp))

    if not iid in lname: continue

    ln=lname[iid]
    dp=depths[iid]
    sn=sname[iid]

    # if iid != 120000004: continue

    tem = pd.read_pickle(fp)
    if tem.empty: continue

    # filters
    if (max(tem.index)-min(tem.index)).days < 4*365: continue # removing monitoring less than 4 years
    if np.isnan(depths[iid]): continue # removing where no depth is reported
    # if depths[iid]>20: continue

    print(iid, end=' ')    
    nval[iid] = len(tem.index)


    # perform Mann-Kendall Trend Test
    temM = tem.drop('SYS_RECORD_ID', axis=1).resample('M').mean()
    temM = temM[temM.index>dtMK]
    if len(temM.index) > 10:
        mktem = mk.original_test(temM['Val'].values)
        MKt[iid] = mktem.Tau
        MKp[iid] = mktem.p


    # fit GAM
    y = tem['Val'].values
    if len(y)<34: # this is still needed
        print('no data')
        continue
    
    tem.drop('SYS_RECORD_ID', axis=1).to_csv(rootdir+'pkl/{}.csv'.format(iid))

    tem['doy'] = tem.index.day_of_year
    X = np.array(tem['doy'].values).reshape(len(tem.index),-1)
    # tem['year'] = tem.index.year
    # X = tem[['doy','year']].to_numpy()

    gam = LinearGAM(n_splines=12).gridsearch(X, y)
    XX = gam.generate_X_grid(term=0, n=500)
    predi = gam.prediction_intervals(XX, width=.9)
    # print(X)
    # print(XX)
    # print(predi)
    # print(gam.predict(XX))

    # plot
    plt.subplot(211)
    plt.plot(XX[:,0], gam.predict(XX), 'r')
    plt.plot(XX[:,0], predi, color='r', ls='--')

    maxVal = max(predi[:,1])
    minVal = min(predi[:,0])
    ampli[iid] = (maxVal-minVal)/2

    plt.axhline(y=maxVal, color='k', ls='--')
    plt.axhline(y=minVal, color='k', ls='--')
    plt.scatter(X[:,0], y, facecolor='gray', edgecolors='none')

    # plt.title('{}: {}\n90% prediction interval, ±{:.3f}m; MK: {} ({:.3f};{:.1e})'.format(iid, lname[iid], ampli[iid], mktem.trend, mktem.Tau, mktem.p))   
    plt.title('{}, {:.1f}m deep\n90% prediction interval, ±{:.3f}m; 10yr Mann-Kendall: {}'.format(sname[iid], depths[iid], ampli[iid], mktem.trend))

    plt.subplot(212)
    plt.plot(tem.index, tem['Val'], 'b', alpha=0.75, label='measured')
    plt.scatter(tem.index, tem['Val'], facecolor='b', edgecolors='none', alpha=0.5)
    plt.plot(tem.index, gam.predict(X), 'r', alpha=0.75, label='fit')
    plt.legend()

    # plt.show()
    # exit()
    # plt.savefig('img/{}.png'.format(iid), dpi=fig.dpi, bbox_inches='tight')
    # plt.close()
    pdf.savefig(fig)
    plt.clf()
    print()
    

pdf.close()

dfLoc['nValues'] = dfLoc['INT_ID'].map(nval)
dfLoc['pyRange'] = dfLoc['INT_ID'].map(ampli)
dfLoc['MannKendall10yrTau'] = dfLoc['INT_ID'].map(MKt)
dfLoc['MannKendall10yrPstat'] = dfLoc['INT_ID'].map(MKp)

# print(dfLoc)
dfLoc.to_pickle(rootdir+'gwvar-summary.py.pkl')
dfLoc.to_csv(rootdir+'gwvar-summary.py.csv', index=False)