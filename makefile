all: index.html

index.html: index.Rmd
	Rscript -e "rmarkdown::render('index.Rmd')"

#index.Rmd: data/clean/data_ger_bundl.csv
	#cd data; make all
