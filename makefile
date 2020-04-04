all: index.html RKI.html all.html

.PHONY: all index.html RKI.html all.html

index.html: index.Rmd
	Rscript -e "rmarkdown::render('index.Rmd')"

RKI.html: RKI.Rmd
	Rscript -e "rmarkdown::render('RKI.Rmd')"

all.html: all.Rmd
	Rscript -e "rmarkdown::render('all.Rmd')"

dependencies: install_dependencies.r
	Rscript install_dependencies.r

#index.Rmd: data/clean/data_ger_bundl.csv
	#cd data; make all
