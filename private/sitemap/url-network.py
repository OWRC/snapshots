

from bs4 import BeautifulSoup
import requests





rooturl = 'https://owrc.github.io/'





#######################################################
# FUNCTIONS
#######################################################
# https://www.geeksforgeeks.org/python-program-to-recursively-scrape-all-the-urls-of-the-website/
coll=dict()
skipped=set()
ids=dict()
def next(href, site):
    # clean-up link
    href = href.replace(rooturl+'/',rooturl)
    href = href.split("#", 1)[0] # remove internal section links
    if href[-2:]=='//': href = href[1:]
    if href[-1:]!="/" and href[-5:]!='.html' and href[-4:]!='.pdf' and href[-4:]!='.zip': href+='/'

    coll[site].append(href)
    if href not in ids: 
        ids[href]=len(ids)
        scrape(href)
        
def scrape(site):
    if site in coll: return
    coll[site] = list()
    if site == 'https://owrc.github.io/info/':
        pass
    r = requests.get(site)
    s = BeautifulSoup(r.text,"html.parser")
    sa = s.find_all('a')

    for i in sa:
        if 'href' in i.attrs:
            href = i.attrs['href']

            if href.startswith('md/'): href = site+href  #############  HARD-CODED, should be fixing page links (check snapshots and info)            

            if href.startswith('#'):
                continue
            elif href in ['Boston-Mills/', 'HighPark/', 'ee-11-1/']:
                continue

            print(site+" >>> "+href.replace(rooturl,'/'))

            if href.startswith(rooturl):
                next(href, site)
            elif href.startswith("/"):
                next(rooturl+href, site)
            elif (href.endswith("/") or href.endswith(".html")) and not href.startswith('http'):
                next(site+href, site)
            else:
                skipped.add(href)                
                    

def filter(root, lst):
    a = list()
    for s in lst:
        ss = s.replace(rooturl,'/')
        if ss[:len(root)]==root:
            a.append(s)
    return a




#################################################################
#################################################################
#################################################################
#################################################################

# calling function
scrape(rooturl)

coll = dict(sorted(coll.items()))
ids=dict()
for href in coll.keys():
    if href not in ids: ids[href]=len(ids)

grps=dict()
grps[rooturl]=0
for href in ids:
    lnk = href.replace(rooturl,"").split("/", 1)[0]
    # hard-coded exclusions 
    if lnk == '': continue
    if not lnk in grps: grps[lnk]=len(grps)



# printing
with open('sites.txt','w') as f: f.write('\n'.join(ids.keys()))
with open('external.txt','w') as f: f.write('\n'.join(sorted(skipped)))


def groupRecurse(root,href,gid):
    grps[href]=gid
    if href in coll:
        slnks = filter(root, coll[href])
        # print(root)
        # print(slnks)
        for h in slnks: 
            if h in grps: continue
            groupRecurse(root,h,gid)

for href in ids:
    lnk = href.replace(rooturl,"").split("/", 1)[0]
    if lnk in grps:
        groupRecurse(lnk, href, grps[lnk])




with open('links.csv', 'w') as f:
    f.write('source,target,value\n')
    for k,v in coll.items():
        if not k in grps:
            print(" ----------          "  + k)
        for a in v:
            f.write("{},{},1\n".format(ids[k], ids[a]))



with open('nodes.csv', 'w') as f:
    f.write('name,group,typ\n')
    for href in ids:
        lnk = href.replace(rooturl,"").split("/", 1)[0]
        if href==rooturl+lnk+'/':
            f.write("{},{},1\n".format(href,grps[lnk]))
        elif href==rooturl:
            f.write("{},{},0\n".format(rooturl,0))
        else:    
            f.write("{},{},2\n".format(href.replace(rooturl,'/'),grps[href]))

