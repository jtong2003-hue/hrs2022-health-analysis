# create_synthetic_data.R
#
# Generates synthetic HRS 2022-like CSV files for reproducibility.
# NOTE: Real HRS 2022 Core data requires free registration at
# https://hrs.isr.umich.edu/data-products. This script produces files with
# the same structure and variable names as the real data but with simulated
# values. Results on synthetic data are illustrative only.

set.seed(2022)

N <- 2000  # synthetic sample size (real HRS 2022 ≈ 15,700 respondents)

if (!dir.exists("data")) dir.create("data")

# ── Respondent IDs ────────────────────────────────────────────────────────────
HHID <- sample(100000:999999, N, replace = FALSE)
PN   <- sample(10:50, N, replace = TRUE)

# ── Section A: Background (h22a_r.csv) ───────────────────────────────────────
# SA019: age (50–95)
h22a <- data.frame(
  HHID  = HHID,
  PN    = PN,
  SA019 = sample(50:95, N, replace = TRUE)
)

write.csv(h22a, "data/h22a_r.csv", row.names = FALSE)
cat("Saved: data/h22a_r.csv\n")

# ── Section C: Health (h22c_r.csv) ───────────────────────────────────────────
# SC001: self-rated health  1=Excellent … 5=Poor
# SC002: health change      1=Better, 2=Same, 3=Worse
# SC005: hypertension       1=yes, 5=no
# SC010: diabetes           1=yes, 5=no
# SC018: cancer             1=yes, 5=no
h22c <- data.frame(
  HHID  = HHID,
  PN    = PN,
  SC001 = sample(1:5, N, replace = TRUE, prob = c(0.11, 0.31, 0.30, 0.19, 0.09)),
  SC002 = sample(1:3, N, replace = TRUE, prob = c(0.20, 0.60, 0.20)),
  SC005 = sample(c(1L, 5L), N, replace = TRUE, prob = c(0.62, 0.38)),
  SC010 = sample(c(1L, 5L), N, replace = TRUE, prob = c(0.30, 0.70)),
  SC018 = sample(c(1L, 5L), N, replace = TRUE, prob = c(0.15, 0.85))
)

write.csv(h22c, "data/h22c_r.csv", row.names = FALSE)
cat("Saved: data/h22c_r.csv\n")

# ── Pre-release Demographics (h22pr_r.csv) ────────────────────────────────────
# SX060_R: sex        1=Male, 2=Female
# SX007_R: education  1=<HS, 2=HS grad, 3=Some college, 4=College+
h22pr <- data.frame(
  HHID    = HHID,
  PN      = PN,
  SX060_R = sample(1:2, N, replace = TRUE, prob = c(0.43, 0.57)),
  SX007_R = sample(1:4, N, replace = TRUE, prob = c(0.15, 0.32, 0.28, 0.25))
)

write.csv(h22pr, "data/h22pr_r.csv", row.names = FALSE)
cat("Saved: data/h22pr_r.csv\n")
cat("Synthetic data generation complete (N =", N, "respondents).\n")
