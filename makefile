all: index.html germany.html all.html

.PHONY: all index.html germany.html all.html

index.html: index.Rmd
	Rscript -e "rmarkdown::render('index.Rmd')"

germany.html: germany.Rmd
	Rscript -e "rmarkdown::render('germany.Rmd')"

all.html: all.Rmd
	Rscript -e "rmarkdown::render('all.Rmd')"

dependencies: install_dependencies.r
	Rscript install_dependencies.r

#index.Rmd: data/clean/data_ger_bundl.csv
	#cd data; make all
