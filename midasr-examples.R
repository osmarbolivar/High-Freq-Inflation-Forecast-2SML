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

# --------------------------
# 3. Create Datetime Indices
# --------------------------
# For this customized example, assume each month is exactly 28 days.
# Monthly dates: one observation every 28 days.
dates_monthly <- seq(from = as.Date("2020-01-01"), by = "28 days", length.out = n_month)

# Weekly dates: observations every 7 days.
dates_weekly <- seq(from = as.Date("2020-01-01"), by = "7 days", length.out = n_week)

# --------------------------
# 4. Simulate the Weekly Predictor
# --------------------------
# Simulate a weekly predictor as an AR(1) process.
x_weekly <- as.numeric(arima.sim(model = list(ar = 0.5), n = n_week))

# Create a zoo object for the weekly predictor with its datetime index.
x_zoo <- zoo(x_weekly, order.by = dates_weekly)

# --------------------------
# 5. Compute the Aggregated Predictor for Each Month
# --------------------------
# The MIDAS regression will use a weighted average of the weekly predictor.
# The fmls() function builds a matrix of lags from the high-frequency data.
# Here we use lags 0:3 (i.e., 4 lags corresponding to 4 weeks per month),
# a frequency ratio m = 4, and the nealmon weight function.
# For simulation, we supply "true" nealmon parameters.
true_par <- c(0.5, -0.2, 0.1)
x_agg <- fmls(x_weekly, 0:3, m, nealmon, par = true_par)

# --------------------------
# 6. Simulate the Monthly Dependent Variable
# --------------------------
# Define true regression parameters.
beta0 <- 1.0               # intercept
beta1 <- 2.0               # slope for the aggregated predictor
sigma_error <- 0.5         # standard deviation of the error term

# Simulate the monthly dependent variable using the aggregated predictor.
error <- rnorm(n_month, mean = 0, sd = sigma_error)
y_monthly <- beta0 + beta1 * x_agg + error

# Create a zoo object for the monthly dependent variable with its datetime index.
y_zoo <- zoo(y_monthly, order.by = dates_monthly)

# --------------------------
# 7. Prepare Data for MIDAS Regression
# --------------------------
# Although our raw data are zoo objects (with date indices), the midasr package
# works on numeric vectors. We extract the core data while still having the original
# zoo objects available for reference or plotting.
data_list <- list(
  y = coredata(y_zoo),       # monthly dependent variable
  x_hf = coredata(x_zoo)     # weekly predictor (renamed to avoid naming conflicts)
)

# --------------------------
# 8. Specify the MIDAS Regression Model
# --------------------------
# We build the formula using fmls() to indicate that for each monthly observation,
# the predictor "x_hf" is represented by its 4 weekly lags (0,1,2,3) using a nealmon weight.
midas_formula <- y ~ fmls(x_hf, 0:3, m, nealmon)

# Supply starting values for the nealmon weight function parameters (typically 3 parameters).
start_list <- list(x_hf = rep(0, 3))

# --------------------------
# 9. Estimate the MIDAS Regression Model
# --------------------------
# midas_r() performs nonlinear least squares estimation of the MIDAS regression.
midas_model <- midas_r(midas_formula, data = data_list, start = start_list)

# --------------------------
# 10. Examine the Results
# --------------------------
# Print a summary of the estimated model.
summary(midas_model)

# Optionally, plot the estimated MIDAS weights.
plot_midas_coef(midas_model, term = "x_hf")
