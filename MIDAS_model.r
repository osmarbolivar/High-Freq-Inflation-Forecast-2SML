# Load required packages (install if not already installed)
if (!require(midasr)) install.packages("midasr")
if (!require(dplyr)) install.packages("dplyr")
library(midasr)
library(dplyr)

# Read in the dataset
data_all <- read.csv("./Data/MIDAS_DATASET.csv", stringsAsFactors = FALSE)

# Separate monthly and weekly observations based on the 'set' variable
# Monthly observations: set equals "train" or "validation"
monthly_data <- filter(data_all, set %in% c("train", "validation"))
# Weekly observations: set equals "test"
weekly_data  <- filter(data_all, set == "test")

# Create a list to hold the series for the MIDAS regression
# The dependent variable (monthly frequency) is "ipc_all"
data_list <- list(
  ipc_all = monthly_data$ipc_all
)

# Identify the high-frequency regressors (all variables except "ipc_all" and "set")
hf_vars <- setdiff(names(data_all), c("ipc_all", "set"))

# For each high-frequency variable, extract the series from the weekly data.
# (It is assumed that the weekly observations are ordered chronologically.)
for (var in hf_vars) {
  data_list[[var]] <- weekly_data[[var]]
}

# Construct the MIDAS regression formula dynamically.
# Here we use fmls() for each high-frequency regressor.
# fmls(x, 0:3, 4, nealmon) specifies lags 0 to 3 (4 lags corresponding to 4 weeks per month)
formula_terms <- paste0("fmls(", hf_vars, ", 0:3, 4, nealmon)")
midas_formula <- as.formula(paste("ipc_all ~", paste(formula_terms, collapse = " + ")))

# Define starting values for the weight functions.
# The nealmon specification typically requires 3 parameters; here we use zeros as starting values.
start_list <- list()
for (var in hf_vars) {
  start_list[[var]] <- rep(0, 3)
}

# Estimate the MIDAS regression model using midas_r.
# The function will use the monthly y and the weekly high-frequency regressors,
# taking into account the frequency ratio of 4.
midas_model <- midas_r(midas_formula, data = data_list, start = start_list)

# Print a summary of the estimated model
summary(midas_model)
