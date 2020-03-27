all: get_rki dati_italia clean_data

.PHONY: get_rki clean_data rm_dirs dati_italia
get_rki:
	mkdir -p rki_data
	# Hauptzeitreihe
	cd rki_data; wget -O RKI_COVID19.csv https://opendata.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0.csv
	# Bundesländer heute
	cd rki_data; wget -O RKI_Corona_Bundeslaender.csv https://opendata.arcgis.com/datasets/ef4b445a53c1406892257fe63129a8ea_0.csv
	# Kreise heute
	cd rki_data; wget -O RKI_Corona_Landkreise.csv https://opendata.arcgis.com/datasets/917fc37a709542548cc3be077a786c17_0.csv

dati_italia:
	if [ ! -d dati_italia ] ; then git clone https://github.com/pcm-dpc/COVID-19.git dati_italia; fi
	cd dati_italia; git pull origin master

clean_data:
	mkdir -p clean
	Rscript --verbose clean.r

clean:
	rm -rf clean rki_data
