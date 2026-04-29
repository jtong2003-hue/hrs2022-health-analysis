# HRS 2022: Health Status in Older Americans

This repository contains an analysis of health status and chronic disease burden in older Americans using the **Health and Retirement Study (HRS) 2022 Core data (Wave 22)**.

## Study Overview

The analysis has three goals:

1. **Describe** the demographic composition of the HRS 2022 sample (age, sex, education)
2. **Characterize** the distribution of self-rated health and prevalence of hypertension, diabetes, and cancer
3. **Examine** the relationship between chronic disease burden and self-rated health

## Data

> **The real HRS 2022 Core data requires free registration** at <https://hrs.isr.umich.edu/data-products>. It is not included in this repository.

The `data/` folder contains **synthetic CSV files** with the same structure as the real data. To regenerate them:

```bash
make data
```

**To use real data**: Download the HRS 2022 Core files from the HRS website, extract the following CSV files into `data/`:
- `h22a_r.csv` — Section A (Background)
- `h22c_r.csv` — Section C (Health conditions)
- `h22pr_r.csv` — Pre-release demographics

## How to Generate the Final Report

There are **two equivalent ways** to reproduce the report. Pick whichever is more convenient:

| Approach | Requires on your machine | Output location |
|----------|--------------------------|-----------------|
| **A. Docker** (recommended for graders / new machines) | only Docker | `report/HRS2022_analysis.html` |
| **B. Local R** | R 4.5.2 + `renv` | `output/HRS2022_analysis.html` |

---

### A. Reproduce with Docker (recommended)

A pre-built image is published on DockerHub:
**<https://hub.docker.com/r/jtong2003/hrs2022-health-analysis>**

You do **not** need R, RStudio, or any R packages installed locally — just Docker.

#### Run (Mac / Linux)

```bash
make docker
```

#### Run (Windows, git-bash)

```bash
make docker-win
```

> Why two targets? Windows git-bash rewrites Unix-style bind-mount paths.
> The `docker-win` target adds a leading `/` to disable that translation.

Either target will:

1. Create an empty `./report/` directory in the project root.
2. Pull `jtong2003/hrs2022-health-analysis:latest` from DockerHub (first run only).
3. Run the container, which regenerates the synthetic data and renders the
   report into the mounted `./report/` directory.

When the command finishes, open **`report/HRS2022_analysis.html`** in any web browser.

These targets have **no Make prerequisites** — a fresh clone can run `make docker` immediately, without first building the image.

#### (Optional) Build the image locally

Only needed if you have modified the `Dockerfile`. End users should not need this.

```bash
make docker-build
# or, equivalently:
docker build -t jtong2003/hrs2022-health-analysis:latest .
```

---

### B. Reproduce with local R

This project uses [`renv`](https://rstudio.github.io/renv/) to lock R package
versions. All packages are recorded in `renv.lock`.

```bash
make install    # restore packages from renv.lock (first time only)
make all        # generate synthetic data + render the report
```

Output is written to `output/HRS2022_analysis.html`.

> You need `renv` itself installed first: `install.packages("renv")`.

---

## Repository Structure

```
.
├── Dockerfile                 # Builds the reproducible image
├── .dockerignore              # Excludes large/local files from the build context
├── Makefile                   # Build rules (local + docker targets)
├── README.md                  # This file
├── .Rprofile                  # Activates renv on project load
├── renv.lock                  # Locked package versions for reproducibility
├── renv/                      # renv settings + activate.R (library is gitignored)
├── create_synthetic_data.R    # Generates synthetic data CSVs
├── HRS2022_analysis.Rmd       # Main analysis document
├── data/                      # Data directory (synthetic CSVs tracked by git)
│   ├── h22a_r.csv             ← Section A: age
│   ├── h22c_r.csv             ← Section C: self-rated health, chronic conditions
│   └── h22pr_r.csv            ← Pre-release: sex, education
├── output/                    # Generated report — local R workflow
│   └── HRS2022_analysis.html
└── report/                    # Generated report — Docker workflow (bind-mounted)
    └── HRS2022_analysis.html
```

---

## Tables

| Table | Generating Code | Description |
|-------|----------------|-------------|
| Table 1. Sample Characteristics | `HRS2022_analysis.Rmd` → chunk **`table1`** | Age, sex, education, self-rated health |
| Table 2. Chronic Condition Prevalence | `HRS2022_analysis.Rmd` → chunk **`table2`** | Hypertension, diabetes, cancer prevalence |

## Figures

| Figure | Generating Code | Description |
|--------|----------------|-------------|
| Figure 1. Age distribution | `HRS2022_analysis.Rmd` → chunk **`fig1-age`** | Histogram with median line |
| Figure 2. Self-rated health | `HRS2022_analysis.Rmd` → chunk **`fig2-health`** | Bar chart by health category |
| Figure 3. Conditions by age group | `HRS2022_analysis.Rmd` → chunk **`fig3-conditions-age`** | Prevalence trends with 95% CI |
| Figure 4. Health by condition count | `HRS2022_analysis.Rmd` → chunk **`fig4-conditions-health`** | Stacked bar chart |

---

*Data source: Health and Retirement Study, 2022 Core Final (Version 1.0). University of Michigan, NIA grant U01AG009740.*
