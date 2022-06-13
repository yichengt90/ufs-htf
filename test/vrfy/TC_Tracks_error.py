# Purpose: plot hurricane track errors from GFDL tc-tracker results.
# Usage: python TC_Tracks_error.py
# Author: Yi-cheng Teng, Jul 8, 2022

from matplotlib import pyplot as plt
import numpy as np
import matplotlib
import geopy.distance

#atm
csv_file = "./trak.gfso.atcfunix.altg.2019071200.atm"
tc = np.recfromcsv(csv_file, names=['stormid', 'count', 'initdate', 'constant', 'atcf', 'leadtime', 'lat','lon','ws','mslp','placehoder', 'thresh', 'neq', 'blank1', 'blank2', 'blank3','blank4','blank5','blank6','blank7','blank8','blank9','blank10'], dtype=None, encoding='utf-8')

#s2s
csv_file2 = "./trak.gfso.atcfunix.altg.2019071200.s2s"
tc2 = np.recfromcsv(csv_file2, names=['stormid', 'count', 'initdate', 'constant', 'atcf', 'leadtime', 'lat','lon','ws','mslp','placehoder', 'thresh', 'neq', 'blank1', 'blank2', 'blank3','blank4','blank5','blank6','blank7','blank8','blank9','blank10'], dtype=None,encoding='utf-8')

#s2sw
csv_file3 = "./trak.gfso.atcfunix.altg.2019071200.s2sw"
tc3 = np.recfromcsv(csv_file3, names=['stormid', 'count', 'initdate', 'constant', 'atcf', 'leadtime', 'lat','lon','ws','mslp','placehoder', 'thresh', 'neq', 'blank1', 'blank2', 'blank3','blank4','blank5','blank6','blank7','blank8','blank9','blank10'], dtype=None,encoding='utf-8')

# Read Best Track data
bal_file ="./data/bal022019_post.dat"
bal = np.recfromcsv(bal_file,delimiter=",",usecols=[0,3,4,5,6],names=['time','lat','lon','ws','mslp'],dtype=None,encoding='utf-8')

# Read the vortex center, lat and lon, from Best Track data
xsb = []
ysb = []
for k in range(len(bal.lat)):
    xsb.append(float(bal.lon[k][1:6])*1*(-1))
    ysb.append(float(bal.lat[k][1:5])*1)

# Read the vortex center, lat and lon, from tc-tracker results for atm
xs1 = []
ys1 = []
for j in range(len(tc.ws)):
    tcstormid=str(tc.stormid[j])
    if tcstormid=='AL' and tc.count[j]=='  02L' and tc.thresh[j]==34:
        xs1.append(float(tc.lon[j][1:5])*0.1*(-1))
        ys1.append(float(tc.lat[j][1:4])*0.1)

# Read the vortex center, lat and lon, from tc-tracker results for s2s
xs2 = []
ys2 = []
for j in range(len(tc2.ws)):
    tc2stormid=str(tc2.stormid[j])
    if tc2stormid=='AL' and tc2.count[j]=='  02L' and tc2.thresh[j]==34:
        xs2.append(float(tc2.lon[j][1:5])*0.1*(-1))
        ys2.append(float(tc2.lat[j][1:4])*0.1)

# Read the vortex center, lat and lon, from tc-tracker results for s2sw
xs3 = []
ys3 = []
for j in range(len(tc3.ws)):
    tc3stormid=str(tc3.stormid[j])
    if tc3stormid=='AL' and tc3.count[j]=='  02L' and tc3.thresh[j]==34:
        xs3.append(float(tc3.lon[j][1:5])*0.1*(-1))
        ys3.append(float(tc3.lat[j][1:4])*0.1)

#calculate trk error
err1 = []
err2 = []
err3 = []
for k in range(len(xs1)):
    corrds_b = (ysb[k],xsb[k])
    coords_1 = (ys1[k],xs1[k])
    coords_2 = (ys2[k],xs2[k])
    coords_3 = (ys3[k],xs3[k])
    err1.append(geopy.distance.geodesic(corrds_b,coords_1).km)
    err2.append(geopy.distance.geodesic(corrds_b,coords_2).km)
    err3.append(geopy.distance.geodesic(corrds_b,coords_3).km)


# Make x axis
t1=np.arange(0,len(err1),1)
t2=np.arange(0,len(err2),1)
t3=np.arange(0,len(err3),1)


# Make the plot
plt.figure(figsize=(8,6))
plt.plot(t1,err1,'.-r',label="ATM")
plt.plot(t2,err2,'.-b',label="S2S")
plt.plot(t3,err3,'.-k',label="S2SW")
plt.legend(loc="upper left")
my_xticks=['0','6','12','18','24','30','36','42','48']
plt.xlabel('Forecast period (h)')
plt.ylabel('Track Forcast error (km)')
plt.xticks(t1,my_xticks)
plt.ylim([0, 100])
plt.xlim([0, len(err1)])
plt.grid(True)
plt.savefig('TC_track_error.png')
