# --------------------------
# 1. Load Required Packages
# --------------------------
if (!require(midasr)) install.packages("midasr")
if (!require(zoo)) install.packages("zoo")
library(midasr)
library(zoo)

# --------------------------
# 2. Set Simulation Parameters
# --------------------------
set.seed(123)              # for reproducibility

n_month <- 100             # number of monthly observations
m <- 4                     # frequency ratio: 4 weeks per month
n_week <- n_month * m      # total number of weekly observations

# True parameters for the nealmon weight function (3 parameters are typical)
true_par <- c(0.5, -0.2, 0.1)

# True regression parameters for simulation
beta0 <- 1.0               # intercept
beta1 <- 2.0               # slope for the aggregated predictor
sigma_error <- 0.5         # standard deviation of the error term

# --------------------------
# 3. Simulate the Weekly Predictor
# --------------------------
# Simulate a weekly predictor (AR(1) process)
x_weekly <- as.numeric(arima.sim(model = list(ar = 0.5), n = n_week))
x_weekly

# --------------------------
# 4. Create the Aggregated Predictor
# --------------------------
# Use fmls() to aggregate the weekly predictor for each month.
# We specify lags 0:3 (i.e., 4 lags corresponding to 4 weeks per month),
# a frequency ratio m = 4, and the nealmon weight function.
# Here we supply the true parameters (for simulation) via the 'par' argument.
x_agg <- fmls(x_weekly, 0:3, m, nealmon, par = true_par)
x_agg

# --------------------------
# 5. Simulate the Monthly Dependent Variable
# --------------------------
# The true process: y[t] = beta0 + beta1 * (aggregated predictor) + error
error <- rnorm(n_month, mean = 0, sd = sigma_error)
y <- beta0 + beta1 * x_agg + error

# --------------------------
# 6. Prepare Data for midas_r
# --------------------------
# IMPORTANT: To avoid duplicate names, assign a unique name to the weekly predictor.
data_list <- list(
  y = y,         # monthly dependent variable
  x_hf = x_weekly  # high-frequency (weekly) predictor renamed to "x_hf"
)

# --------------------------
# 7. Specify the MIDAS Regression Model
# --------------------------
# The MIDAS term is defined using fmls(). Here:
# - 'x_hf' is our high-frequency variable.
# - '0:3' defines the lags (weeks 0, 1, 2, and 3).
# - 'm' (which is 4) is the frequency ratio.
# - 'nealmon' is the weight function.
midas_formula <- y ~ fmls(x_hf, 0:3, m, nealmon)

# For estimation, supply starting values for the nealmon parameters.
# The nealmon weight function typically has 3 parameters.
start_list <- list(x_hf = rep(0, 3))

# --------------------------
# 8. Estimate the MIDAS Regression Model
# --------------------------
# The midas_r() function performs nonlinear least squares estimation.
# It estimates both the regression coefficient (beta1) and the parameters of the weight function.
midas_model <- midas_r(midas_formula, data = data_list, start = start_list)

# --------------------------
# 9. Examine the Results
# --------------------------
# Print the summary of the estimated MIDAS model.
summary(midas_model)

# (Optional) Visualize the estimated MIDAS weights.
plot_midas_coef(midas_model, term = "x_hf")
