vpath %.R scripts

# export PATH := $(PATH):scripts

nbcdStates := AL AR AZ CA CO CT DC DE East_TX 
nbcdStates += FL GA IA ID IL IN KS KY LA MA MD 
nbcdStates += ME MI MN MO MS MT NC ND NE NH NJ 
nbcdStates += NM NV NY OH OK OR PA RI SC SD TN 
nbcdStates += UT VA VT WA WestTX WI WV WY

stateZips = $(patsubst %,%.zip,$(nbcdStates))
stateTifs = $(patsubst %,%.tif,$(nbcdStates))

SCRIPTS = download.R


download: download.R
	Rscript --vanilla --quiet $<
	find atlas.whrc.org -name '*.tgz' -execdir tar xzkf '{}' \;

$(stateZips):
	wget -nv -c -x ftp://atlas.whrc.org/gfiske/US/FIA_biomass/$@

$(stateTifs): %.tif: %.zip
	find atlas.whrc.org/gfiske/US/FIA_biomass/ -name $< -execdir unzip -n \{\} \;

$(nbcdStates): %: %.tif

states: $(nbcdStates)

$(SCRIPTS): tangle

tangle: nbcd.org
	emacs --batch --file=nbcd.org -f org-babel-tangle 2>&1 | grep tangle
	rsync -arq tangle/ scripts 
	chmod u+x scripts/*

clean:
	find atlas.whrc.org -type f -not -name '*.tgz' -delete
	find atlas.whrc.org -type f -not -name '*.zip' -delete

distclean: clean 
	find atlas.whrc.org -name '*.zip' -or -name '*.tgz' -delete

.PHONY: download $(nbcdStates) states tangle