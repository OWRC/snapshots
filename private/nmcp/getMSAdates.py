from datetime import datetime
from pymmio import files


with  open("getMSAdates.txt", "w") as f:
    for fp in files.dirList('M:/model_archive/_MSA',"pdf"):
        sdt = files.getFileName(fp)[:6]
        dt = datetime.strptime(sdt, "%y%m%d")
        print(dt)
        f.write(sdt+'\n')