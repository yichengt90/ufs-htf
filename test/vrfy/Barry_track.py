# Purpose: plot time series of the maximum wind speed at the vortex center from GFDL tc-tracker results.
# Usage: python TC_WS_TimeSeries.py

#from matplotlib import pyplot as plt
#import numpy as np
#import matplotlib
from matplotlib import pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np
import matplotlib.cm as cm
import matplotlib.colors as co
import matplotlib


# Define map
m = Basemap(projection='cyl', \
        llcrnrlat= 25, urcrnrlat= 40, \
        llcrnrlon= -100, urcrnrlon= -80, \
        resolution='l')

# Define plot size
fig, ax = plt.subplots(figsize=(8,8))

# Read atm vortext tracker results
csv_file = "./trak.gfso.atcfunix.altg.2019071200.atm"
tc = np.recfromcsv(csv_file, names=['stormid', 'count', 'initdate', 'constant', 'atcf', 'leadtime', 'lat','lon','ws','mslp','placehoder', 'thresh', 'neq', 'blank1', 'blank2', 'blank3','blank4','blank5','blank6','blank7','blank8','blank9','blank10'], dtype=None, encoding='utf-8')

# Read GFSv16beta vortext tracker results
csv_file2 = "./trak.gfso.atcfunix.altg.2019071200.s2s"
tc2 = np.recfromcsv(csv_file2, names=['stormid', 'count', 'initdate', 'constant', 'atcf', 'leadtime', 'lat','lon','ws','mslp','placehoder', 'thresh', 'neq', 'blank1', 'blank2', 'blank3','blank4','blank5','blank6','blank7','blank8','blank9','blank10'], dtype=None,encoding='utf-8')

# Read Best Track data
bal_file ="./data/bal022019_post.dat"
bal = np.recfromcsv(bal_file,delimiter=",",usecols=[0,3,4,5,6],names=['time','lat','lon','ws','mslp'],dtype=None,encoding='utf-8')


# Initialize blank lists
xs1 = []
ys1 = []
xs2 = []
ys2 = []

xs12 = []
ys12 = []
xs22 = []
ys22 = []

tclon =[]
tclat=[]
ws=[]
bxs1 = []
bys1 = []
ballon=[]
ballat=[]

# Prepare color map based on vortex center maximum wind speed
cmap=plt.cm.jet
norm=co.Normalize(vmin=9,vmax=55)
colors=plt.cm.ScalarMappable(norm,cmap)
col=colors.to_rgba(tc.ws)
bcol=colors.to_rgba(bal.ws)
col2=colors.to_rgba(tc2.ws)

# Read the vortex center, lat and lon, from Best Track data
for k in range(len(bal.lat)):
    ballon=float(bal.lon[k][1:6])*1*(-1)
    ballat=float(bal.lat[k][1:5])*1
    lonn,latt=ballon,ballat
    xptt,yptt=m(lonn,latt)
    lonptt,latptt=m(xptt,yptt,inverse=True)
    bxs1.append(lonn)
    bys1.append(latt)
cs1=m.plot(bxs1, bys1, linestyle='--',color='Black',label='Best Track')

# Read the vortex center, lat and lon, from Best Track data to make colored dots along with the tracks
bxs1 = []
bys1 = []
ballon=[]
ballat=[]
count=0
for k in range(len(bal.lat)):
    ballon=float(bal.lon[k][1:6])*1*(-1)
    ballat=float(bal.lat[k][1:5])*1
    lonn,latt=ballon,ballat
    xptt,yptt=m(lonn,latt)
    lonptt,latptt=m(xptt,yptt,inverse=True)
    bxs1.append(lonn)
    bys1.append(latt)
    m.plot(bxs1[count], bys1[count], marker='o',color=bcol[k,:])
    count=count+1

# Read the vortex center, lat and lon, from tc-tracker results for GFSv15p2
for j in range(len(tc.ws)):
    tcstormid=str(tc.stormid[j])
    print(tcstormid)
    if tcstormid=='AL' and tc.count[j]=='  02L' and tc.thresh[j]==34:
        tclon=float(tc.lon[j][1:5])*0.1*(-1)
        tclat=float(tc.lat[j][1:4])*0.1
        lon, lat = tclon, tclat
        xpt, ypt = m(lon, lat)
        lonpt, latpt = m(xpt, ypt, inverse=True)
        xs1.append(lon)
        ys1.append(lat)
cs2=m.plot(xs1, ys1, linestyle='--',color='Red',label='atm_c96_GFSv17_p8c')


# Read the vortex center, lat and lon, from tc-tracker results for GFSv15p2 to make colored dots along with the tracks
xs1 = []
ys1 = []
xs2 = []
ys2 = []
tclon =[]
tclat=[]
count=0
for j in range(len(tc.ws)):
    tcstormid=str(tc.stormid[j])
    if tcstormid=='AL' and tc.count[j]=='  02L' and tc.thresh[j]==34:
        tclon=float(tc.lon[j][1:5])*0.1*(-1)
        tclat=float(tc.lat[j][1:4])*0.1
        lon, lat = tclon, tclat
        xpt, ypt = m(lon, lat)
        lonpt, latpt = m(xpt, ypt, inverse=True)
        xs1.append(lon)
        ys1.append(lat)
        m.plot(xs1[count], ys1[count], marker='o',color=col[j,:])
        count=count+1
        print(count)

# Read the vortex center, lat and lon, from tc-tracker results for GFSv16beta
for j in range(len(tc2.ws)):
    tc2stormid=str(tc2.stormid[j])
    print(tc2stormid)
    if tc2stormid=='AL' and tc2.count[j]=='  02L' and tc2.thresh[j]==34:
        tc2lon=float(tc2.lon[j][1:5])*0.1*(-1)
        tc2lat=float(tc2.lat[j][1:4])*0.1
        lon2, lat2 = tc2lon, tc2lat
        xpt2, ypt2 = m(lon2, lat2)
        lonpt2, latpt2 = m(xpt2, ypt2, inverse=True)
        xs12.append(lon2)
        ys12.append(lat2)
cs22=m.plot(xs12, ys12, linestyle='--',color='Blue',label='s2s_c96_GFSv17_p8c')

# Read the vortex center, lat and lon, from tc-tracker results for GFSv16beta to make colored dots along with the tracks
xs12 = []
ys12 = []
xs22 = []
ys22 = []
tc2lon =[]
tc2lat=[]
count2=0
for j in range(len(tc2.ws)-1):
    tc2stormid=str(tc2.stormid[j])
    if tc2stormid=='AL' and tc2.count[j]=='  02L' and tc2.thresh[j]==34:
        tc2lon=float(tc2.lon[j][1:5])*0.1*(-1)
        tc2lat=float(tc2.lat[j][1:4])*0.1
        lon2, lat2 = tc2lon, tc2lat
        xpt2, ypt2 = m(lon2, lat2)
        lonpt2, latpt2 = m(xpt2, ypt2, inverse=True)
        xs12.append(lon2)
        ys12.append(lat2)
        m.plot(xs12[count2], ys12[count2], marker='o',color=col2[j,:])
        count2=count2+1

# Draw coastline
m.drawcoastlines()
m.drawcountries()
m.drawstates()
m.drawmapboundary(fill_color='#99ffff')
m.fillcontinents(color='white',lake_color='#99ffff')
colors.set_array([])

# Show and save the plot
plt.legend()
plt.title('Hurricane Barry Tracks from 00Z 12 Jul to 00Z 14 Jul 2019')
plt.colorbar(colors,fraction=0.035,pad=0.04,label='vortex maximum 10-m wind (kt)')
#plt.show()
plt.savefig('./Tracker_Barry_ufs.png')
