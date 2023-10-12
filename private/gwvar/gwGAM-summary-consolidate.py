
import os
from PyPDF2 import PdfMerger, PdfReader

# Call the PdfFileMerger
mergedObject = PdfMerger()


indir = 'E:/Sync/@dev/pages_owrc/snapshots-private/gwvar'

def getFromDir(d):
    l = []
    for f in os.listdir(d):
        if f.endswith(".pdf"):
            l.append(os.path.join(d, f))
    return l

for fp in getFromDir(indir+'/pkl'):
    print(fp)
    mergedObject.append(PdfReader(fp, 'rb'))
 
 
mergedObject.write(indir + "/gwGAM-summary.pdf")


