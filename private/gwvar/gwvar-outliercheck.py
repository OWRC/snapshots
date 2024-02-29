
import pandas as pd
import sqlalchemy
from pymmio.ascii import readLines
import matplotlib.pyplot as plt
# from matplotlib.backends.backend_pdf import PdfPages
from tqdm import tqdm


cnxn = sqlalchemy.create_engine("mssql+pyodbc://sqlyc-mm:dt82Wa35@cloca_oak_master")


# # create a PdfPages object
# pdf = PdfPages('pkl/gwvar-summary.py-outliers-check.pdf')
# fig = plt.figure()

lns = readLines('pkl/gwvar-summary.py-outliers.txt')
for ln in tqdm(lns):
    iln = list(map(int, ln.replace('{',"").replace('}',"").split(",")))
    iid = iln[0]
    rids = iln[1:]
    # print(iid)
    # print(rids[:4])
    q = """SELECT SYS_RECORD_ID, RD_DATE as Date, RD_VALUE as Val, REC_STATUS_CODE
        FROM OAK_20160831_MASTER.dbo.D_INTERVAL_TEMPORAL_{} 
        WHERE RD_VALUE IS NOT NULL 
        AND RD_NAME_CODE = {} 
        -- AND REC_STATUS_CODE < 100
        AND INT_ID = {} 
        ORDER BY RD_DATE""".format(2,629,iid)
    tem = pd.read_sql(q, cnxn).set_index('Date')
    if tem.empty: continue

    ax = tem[tem.REC_STATUS_CODE<100].plot(y='Val', title=str(iid))
    tem[tem.REC_STATUS_CODE==114].plot(ax=ax, y='Val', style='.')
    ax.legend(["kept", "outlier"])

    # plt.show()
    plt.savefig('pkl/outliers/{}.pdf'.format(iid), bbox_inches='tight')
    plt.close() 
    break   

#     pdf.savefig(fig)
#     plt.clf()
#     plt.close()
    
# pdf.close()