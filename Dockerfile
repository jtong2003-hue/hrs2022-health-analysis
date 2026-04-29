# syntax=docker/dockerfile:1
#
# HRS 2022 Health Status Analysis — reproducible report image
#
# Base: rocker/r-ver pins an exact R version and configures Posit Package
# Manager so that renv::restore() pulls *binary* packages (fast, no compile).

FROM rocker/r-ver:4.5.2

# ─── System libraries required by tidyverse + rmarkdown ──────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
        pandoc \
        make \
        git \
        libxml2-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libfontconfig1-dev \
        libfreetype6-dev \
        libpng-dev \
        libtiff5-dev \
        libjpeg-dev \
        libharfbuzz-dev \
        libfribidi-dev \
        libicu-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /project

# ─── Restore R packages from renv.lock (cached as a separate layer) ──────────
COPY renv.lock         renv.lock
COPY .Rprofile         .Rprofile
COPY renv/activate.R   renv/activate.R
COPY renv/settings.json renv/settings.json

RUN R -e "install.packages('renv', repos = 'https://packagemanager.posit.co/cran/latest')" \
 && R -e "renv::restore(prompt = FALSE)"

# ─── Copy the rest of the project ────────────────────────────────────────────
COPY . /project

# Make sure the bind-mount target exists even if the host forgets to create it.
RUN mkdir -p /project/report

# Default: regenerate synthetic data + render the report into /project/report
CMD ["make", "report-docker"]
