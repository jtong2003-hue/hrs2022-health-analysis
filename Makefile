# Makefile — HRS 2022 Health Status Analysis
#
# Local (R installed on host):
#   make install    — restore R package environment from renv.lock
#   make data       — generate synthetic data CSVs
#   make report     — render HTML report into ./output  (requires data)
#   make all        — data + report
#   make clean      — remove generated report
#
# Docker (no R needed on host, only Docker):
#   make docker     — render report into ./report  (Mac / Linux)
#   make docker-win — render report into ./report  (Windows git-bash)
#   make docker-build — build the image locally    (optional)
#   make docker-push  — push the image to DockerHub (maintainer only)

RSCRIPT      = Rscript
OUTPUT       = output
DOCKER_IMAGE = jtong2003/hrs2022-health-analysis:latest

.PHONY: all install report data clean \
        docker docker-win docker-build docker-push report-docker

all: data report

## install: restore R package environment from renv.lock
install:
	$(RSCRIPT) -e "renv::restore()"

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

# ─── Docker targets ──────────────────────────────────────────────────────────
# These targets have NO prerequisites by design: a fresh clone should be able
# to run `make docker` and get a compiled report without first building the
# image locally — Docker auto-pulls $(DOCKER_IMAGE) from DockerHub.

## docker: pull image from DockerHub and render report into ./report (Mac/Linux)
docker:
	mkdir -p report
	docker run --rm -v "$(CURDIR)/report":/project/report $(DOCKER_IMAGE)

## docker-win: same as `docker`, but for Windows git-bash users.
##             git-bash mangles bind-mount paths; the leading / is the fix.
docker-win:
	mkdir -p report
	docker run --rm -v "/$(CURDIR)/report":/project/report $(DOCKER_IMAGE)

## docker-build: build the docker image locally (only needed when modifying
##               the Dockerfile; users running `make docker` do NOT need this).
docker-build:
	docker build -t $(DOCKER_IMAGE) .

## docker-push: push the image to DockerHub (maintainer only; requires login).
docker-push:
	docker push $(DOCKER_IMAGE)

## report-docker: invoked *inside* the container; renders into ./report.
##                Not intended to be run directly on the host.
report-docker:
	mkdir -p report
	$(RSCRIPT) create_synthetic_data.R
	$(RSCRIPT) -e "rmarkdown::render('HRS2022_analysis.Rmd', output_dir='report', knit_root_dir=getwd())"
