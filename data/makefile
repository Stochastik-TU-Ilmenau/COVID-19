all: johns_hopkins clean_data

.PHONY: johns_hopkins clean_data clean

johns_hopkins:
	if [ ! -d johns_hopkins ] ; then  git clone https://github.com/CSSEGISandData/COVID-19 johns_hopkins; fi
	cd johns_hopkins; git pull origin master

clean_data:
	mkdir -p clean
	Rscript --verbose clean.r

clean:
	rm -rf clean rki_data
