vpath %.R scripts

# export PATH := $(PATH):scripts

nbcdStates := AL AR AZ CA CO CT DC DE East_TX 
nbcdStates += FL GA IA ID IL IN KS KY LA MA MD 
nbcdStates += ME MI MN MO MS MT NC ND NE NH NJ 
nbcdStates += NM NV NY OH OK OR PA RI SC SD TN 
nbcdStates += UT VA VT WA WestTX WI WV WY

statePath := atlas.whrc.org/gfiske/US/FIA_biomass/

stateZips = $(patsubst %,$(statePath)%.zip,$(nbcdStates))
stateTifs = $(patsubst %,$(statePath)%.tif,$(nbcdStates))
stateVrts = $(patsubst %,$(statePath)%.vrt,$(nbcdStates))

nlcdProj4 := +proj=aea +lat_1=29.5 +lat_2=45.5 
nlcdProj4 += +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 
nlcdProj4 += +no_defs +a=6378137 +rf=298.257222101 +to_meter=1


# Ideally we would use the non-overlapping state files and merge them
# into a single virtual raster that is in the projections of the cUSA
# NLCD, but NBCD v2 is only available by zones  . . .

nbcd.vrt: $(stateVrts)
	gdalbuildvrt -overwrite $@ $^

$(nbcdStates): %: %.tif

states: $(nbcdStates)

$(stateVrts): %.vrt: %.tif
	gdalwarp -overwrite -t_srs '$(nlcdProj4)' \
	  -of VRT -srcnodata 65536 -dstnodata 65536 \
	  $< $@

$(stateTifs): %.tif: %.zip
	unzip -n -d $(dir $<) $<

$(stateZips):
	wget -nv -c -x ftp://$@


# . . . so for now we grab the publicly published version, which is by
# mapping zones

SCRIPTS = download.R buildVrt.sh

execute: $(SCRIPTS)
	emacs --quick --batch \
	  --file=nbcd.org -f org-babel-execute-buffer
#	Rscript --vanilla --quiet $<
#	find atlas.whrc.org -name '*.tgz' -execdir tar xzkf '{}' \;


$(SCRIPTS): tangle

tangle: nbcd.org
	emacs --quick --batch \
	  --file=nbcd.org -f org-babel-tangle 2>&1 \
	  | grep tangle
	rsync -arq tangle/ scripts 
	chmod u+x scripts/*

clean:
	find atlas.whrc.org -type f -not -name '*.tgz' -delete
	find atlas.whrc.org -type f -not -name '*.zip' -delete

distclean: clean 
	find atlas.whrc.org -name '*.zip' -or -name '*.tgz' -delete

.PHONY: download $(nbcdStates) states vrts tangle
