




# from pathlib import Path

# for path in Path(searchDir).rglob('*.html'):
#     print(path.name)


import fnmatch
import os



searchDir = "E:/Sync/@dev/pages_owrc/snapshots-private"
c=0
for root, dirnames, filenames in os.walk(searchDir):
    for filename in fnmatch.filter(filenames, '*.html'):
        if "minichart" in root: continue
        if "-old" in filename: continue
        print(str(c+1)+"  "+os.path.join(root, filename))
        c+=1