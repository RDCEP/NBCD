
library( stringr)
library( plyr)
library( doMC)

registerDoMC()

Sys.setenv( WGETRC= "./.wgetrc")

url <- "http://atlas.whrc.org/NBCD2000/mapping_zone_shapefile.zip"
download.file( url, basename( url), method= "wget", extra= "-nv")
unzip( basename( url), exdir= "shp")

http <- "http://atlas.whrc.org/NBCD2000"
mz <- str_pad( c( 1:10, 12:36, "37a", "37b", 38:66), 2, pad= "0")
fia <- sprintf( "NBCD2000_MZ%s/NBCD_MZ%s_FIA_ALD_biomass.tgz", mz, mz) 
url <- paste( http, fia, sep= "/")

wgetWithPath <-
  function( url,
           dest= str_replace( url, "http://", ""),
           method= "wget",
           ...) {
    dir.create( dirname( dest),
               recursive= TRUE,
               showWarnings= FALSE)
    download.file( url, dest, method, ...)
  }

res <- llply( url, wgetWithPath, extra= "-nv -nc", .parallel= TRUE)
