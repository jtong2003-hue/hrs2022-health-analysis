# Makefile — HRS 2022 Health Status Analysis
# Usage:
#   make data    — generate synthetic data CSVs
#   make report  — render HTML report  (requires data)
#   make all     — data + report
#   make clean   — remove generated report

RSCRIPT = Rscript
OUTPUT  = output

.PHONY: all report data clean

all: data report

## data: generate synthetic HRS 2022 CSV files
data: data/h22a_r.csv data/h22c_r.csv data/h22pr_r.csv

data/h22a_r.csv data/h22c_r.csv data/h22pr_r.csv: create_synthetic_data.R
	$(RSCRIPT) create_synthetic_data.R

## report: render the analysis HTML report
report: $(OUTPUT)/HRS2022_analysis.html

$(OUTPUT):
	mkdir -p $(OUTPUT)

$(OUTPUT)/HRS2022_analysis.html: HRS2022_analysis.Rmd data/h22a_r.csv data/h22c_r.csv data/h22pr_r.csv | $(OUTPUT)
	$(RSCRIPT) -e "rmarkdown::render('HRS2022_analysis.Rmd', output_dir='$(OUTPUT)', knit_root_dir=getwd())"

## clean: remove generated HTML report
clean:
	rm -f $(OUTPUT)/*.html
