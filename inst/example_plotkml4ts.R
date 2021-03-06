## Not run: # load input data:
data(barxyz)
# define the projection system:
prj = "+proj=tmerc +lat_0=0 +lon_0=18 +k=0.9999 +x_0=6500000 +y_0=0 +ellps=bessel +units=m 
+towgs84=550.499,164.116,475.142,5.80967,2.07902,-11.62386,0.99999445824"
library(sp)
coordinates(barxyz) <- ~x+y
proj4string(barxyz) <- CRS(prj)
data(bargrid)
coordinates(bargrid) <- ~x+y
gridded(bargrid) <- TRUE
proj4string(bargrid) <- CRS(prj)
# fit a variogram and generate simulations:
library(gstat)
Z.ovgm <- vgm(psill=1352, model="Mat", range=650, nugget=0, kappa=1.2)
sel <- runif(length(barxyz$Z))<.2  # Note: this operation can be time consuming
sims <- krige(Z~1, barxyz[sel,], bargrid, model=Z.ovgm, nmax=20, nsim=10, debug.level=-1) 
# specify the cross-section:
t1 <- Line(matrix(c(bargrid@bbox[1,1],bargrid@bbox[1,2],5073012,5073012), ncol=2))
transect <- SpatialLines(list(Lines(list(t1), ID="t")), CRS(prj))
# glue to a RasterBrickSimulations object:
bardem_sims <- new("RasterBrickSimulations", variable = "elevations", 
  sampled = transect, realizations = brick(sims))
# plot the whole project and open in Google Earth:
data(R_pal)
plotKML(bardem_sims, colour_scale = R_pal[[4]])
