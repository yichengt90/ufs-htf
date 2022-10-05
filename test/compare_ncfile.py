#!/usr/bin/env python
import sys
import numpy as np
from netCDF4 import Dataset
from warnings import filterwarnings

#turn off np.bool warnings
filterwarnings(action='ignore', category=DeprecationWarning, message='`np.bool` is a deprecated alias')

#
def mae(true, predictions):
    true, predictions = np.array(true), np.array(predictions)
    return np.nanmean(np.abs(true - predictions))

#
tol=np.float64(sys.argv[3])

#
with Dataset(sys.argv[1]) as nc1, Dataset(sys.argv[2]) as nc2:
  # Check if the list of variables are the same
  if nc1.variables.keys()!=nc2.variables.keys():
    print(".........Error: Variables are different")
    sys.exit(2)

  for varname in nc1.variables.keys():
    if varname == "time_iso":
      continue
    # First check if each variable has the same dimension
    if np.shape(nc1[varname][:])!=np.shape(nc2[varname][:]):
      print(".........Error: ",varname,"dimension is different")
      sys.exit(2)
    # If dimension is the same, compare data
    else:
      diff = np.nanmean(nc2[varname][:])-np.nanmean(nc1[varname][:])
      error = mae(nc1[varname][:], nc2[varname][:])

      if (np.abs(diff)) > tol:
      #if (error) > tol:
        print(".........Warning: ",varname,"is different; abs diff is", np.abs(diff))
