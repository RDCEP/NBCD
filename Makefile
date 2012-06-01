vpath %.R scripts

# export PATH := $(PATH):scripts
SCRIPTS = download.R

download: download.R
	Rscript --vanilla --quiet $<
	find atlas.whrc.org -name '*.tgz' -execdir tar xzkf '{}' \;

$(SCRIPTS): tangle

tangle: nbcd.org
	emacs --batch --file=nbcd.org -f org-babel-tangle 2>&1 | grep tangle
	rsync -arq tangle/ scripts 
	chmod u+x scripts/*
