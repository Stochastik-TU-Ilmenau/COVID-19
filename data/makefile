all: johns_hopkins get_rki clean_data

.PHONY: johns_hopkins get_rki clean_data clean

johns_hopkins:
	if [ ! -d johns_hopkins ] ; then  git clone https://github.com/CSSEGISandData/COVID-19 johns_hopkins; fi
	cd johns_hopkins; git pull origin master

d=`date +%Y-%m-%d`
get_rki:
	mkdir -p rki_data
	# csv seems unreliable use arcgis query api instead
	cd rki_data; wget -O "RKI_COVID19_orig.csv" "https://github.com/robert-koch-institut/SARS-CoV-2_Infektionen_in_Deutschland/raw/master/Aktuell_Deutschland_SarsCov2_Infektionen.csv"; mv RKI_COVID19_orig.csv RKI_COVID19_$d.csv
	#python3 rki_query.py
	#cd rki_data; mv RKI_COVID19.csv RKI_COVID19_$d.csv

clean_data:
	mkdir -p clean
	Rscript --verbose clean.r

clean:
	rm -rf clean rki_data
