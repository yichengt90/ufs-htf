# Purpose: plot time series of the maximum wind speed at the vortex center from GFDL tc-tracker results.
# Usage: python TC_WS_TimeSeries.py

from matplotlib import pyplot as plt
import numpy as np
import matplotlib


# Read atm vortext tracker results
csv_file = "./trak.gfso.atcfunix.altg.2019071100.atm"
tc = np.recfromcsv(csv_file, names=['stormid', 'count', 'initdate', 'constant', 'atcf', 'leadtime', 'lat','lon','ws','mslp','placehoder', 'thresh', 'neq', 'blank1', 'blank2', 'blank3','blank4','blank5','blank6','blank7','blank8','blank9','blank10'], dtype=None, encoding='utf-8')

# Read GFSv16beta vortext tracker results
csv_file2 = "./trak.gfso.atcfunix.altg.2019071100.s2s"
tc2 = np.recfromcsv(csv_file2, names=['stormid', 'count', 'initdate', 'constant', 'atcf', 'leadtime', 'lat','lon','ws','mslp','placehoder', 'thresh', 'neq', 'blank1', 'blank2', 'blank3','blank4','blank5','blank6','blank7','blank8','blank9','blank10'], dtype=None,encoding='utf-8')

# Read Best Track data
bal_file ="./data/bal022019_post.dat"
#bal = np.recfromcsv(bal_file,unpack=True,delimiter=",",usecols=[0,2,6,7,8,9,10,11],names=['stormid','time','lat','lon','ws','mslp','intens','thresh'],dtype=None)
bal = np.recfromcsv(bal_file,delimiter=",",usecols=[0,3,4,5,6],names=['time','lat','lon','ws','mslp'],dtype=None,encoding='utf-8')

# Read in wind speed from Best Track Data
balws=[]
for k in range(len(bal.lat)):
    balwsd=float(bal.ws[k])
    balws.append(balwsd)

# Read in wind speed from atm 
tcws=[]
for j in range(len(tc.ws)):
    tcstormid=str(tc.stormid[j])
    if tcstormid=='AL' and tc.thresh[j]==34:
        tcwsd=float(tc.ws[j])
        tcws.append(tcwsd)

# Read in wind speed from GFSv16beta
tc2ws=[]
for j in range(len(tc2.ws)):
    tc2stormid=str(tc2.stormid[j])
    if tc2stormid=='AL' and tc2.thresh[j]==34:
        tc2wsd=float(tc2.ws[j])
        tc2ws.append(tc2wsd)

# Make x axis
#t=np.arange(0,16,1)
t=np.arange(0,len(tcws),1)
t2=np.arange(0,len(tc2ws),1)
tb=np.arange(0,len(balws),1)


# Make the plot
plt.figure(figsize=(8,6))
plt.plot(t,tcws,'.-r',label="atm_c96_GFSv17_p8c")
plt.plot(t2,tc2ws,'.-b',label="s2s_c96_GFSv17_p8c")
plt.plot(tb,balws,'.-k',label="Best Track")
plt.legend(loc="upper left")
my_xticks=['11/00z','','11/12z','','12/00z','','12/12z','','13/00z','','13/12z','','14/00z','','14/12z','']
plt.xlabel('Date/Time (UTC)')
plt.ylabel('Maximum surface wind (kt)')
frequency=2
plt.xticks(tb,my_xticks)
# plt.show()
plt.savefig('./tracker_ws_Barry_ufs.png')
