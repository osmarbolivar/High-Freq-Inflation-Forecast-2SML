library(midasr)  # loads the midasr package
library(ggplot2) 
library(dplyr)  
library(tidyr)  


# Read the MIDAS dataset
midas_data <- read.csv('./Data/MIDAS_DATASET.csv')
View(midas_data)

y = na.omit(midas_data$ipc_all)
typeof(y)
cat("Observations in dependent variables are", sum(!is.na(y)), "\n")

x = midas_data$tomato_tj[midas_data$set == "test"]
typeof(y)
cat("Observations in covariates are", sum(!is.na(x)), "\n")
cat("Observations when covariates split into 4 weeks:", sum(!is.na(x))/4, "\n")

## Align data
#nx <- ts(x, start = start(x), frequency = 52)
nx <- ts(x, start = start(x), frequency = 48)
ny <- ts(y, start = start(x), frequency = 12)

# Plot nx and ny in the same plot
plot(nx, type = "l", col = "blue", lwd = 2, ylab = "Values", xlab = "Time", main = "nx and ny Time Series")
lines(ny, col = "red", lwd = 2)
legend("topright", legend = c("nx", "ny"), col = c("blue", "red"), lty = 1, lwd = 2)







# Define the MIDAS regression model
midas_model <- midas_r(y ~ mls(x, 0:11, 4, nbeta), start = list(nbeta = c(0.5, 0.5, 0.5)))
# Display the summary of the model
summary(midas_model)



## Align data
nx <- ts(midas_data$ipc_all, start = start(x), frequency = 12)
ny <- ts(c(rep(NA, 33), yg, NA), start = start(x), frequency = 4)



## Estimate the models
beta0 <- midas_r(y ~ mls(y, 1, 1) + mls(x, 3:11, 3, nbeta), start = list(xx = c(1.7, 1, 5)))


beta0 <- midas_r(yy ~ mls(yy, 1, 1) + mls(xx, 3:11, 3, nbeta), start = list(xx = c(1.7, 1, 5)))
coef(beta0)

?mls
