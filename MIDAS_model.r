# Load required packages (install if not already installed)
if (!require(midasr)) install.packages("midasr")
if (!require(dplyr)) install.packages("dplyr")
library(midasr)
library(dplyr)

# Read in the dataset
data_all <- read.csv("./Data/MIDAS_DATASET.csv", stringsAsFactors = FALSE)
View(data_all)

# Separate monthly and weekly observations based on the 'freq' variable
# Monthly observations
monthly_data <- filter(data_all, freq == "month" & set == "train")
View(monthly_data)
# Weekly observations
weekly_data  <- filter(data_all, set == "train") 
View(weekly_data)

y = monthly_data$ipc_all %>% as.numeric()
x = weekly_data$sugar_sc %>% as.numeric()

length(y)
length(x)
length(x)/4

# ------------------------ ONE PREDICTOR MIDAS REGRESSION ------------------------
# Ensure the lengths of y and x are compatible for MIDAS regression
# Aggregate weekly data (x) to match the monthly frequency of y
x_agg <- sapply(seq(1, length(x), by = 4), function(i) mean(x[i:(i+3)], na.rm = TRUE))
# Ensure y and x_agg have the same length
y <- y[1:length(x_agg)]
# Estimate the MIDAS regression model
midas_model <- midas_r(y ~ mls(x, 0:3, 4), start = NULL)
# Display the summary of the model
summary(midas_model)


# ------------------------ MULTIPLE PREDICTORS MIDAS REGRESSION ------------------------
colnames(weekly_data)[3:36]
all_feats = colnames(weekly_data)[3:36] %>% as.character()
all_feats
View(weekly_data[,all_feats])

# Aggregate all weekly predictors to match the monthly frequency
x_agg_feats <- lapply(all_feats, function(feat) {
  sapply(seq(1, nrow(weekly_data), by = 4), function(i) mean(weekly_data[i:(i+3), feat], na.rm = TRUE))
})
# Convert the list of aggregated predictors to a data frame
x_agg_feats <- as.data.frame(x_agg_feats)
colnames(x_agg_feats) <- all_feats
# Ensure y and x_agg_feats have compatible lengths
y <- y[1:nrow(x_agg_feats)]
# Create the formula explicitly using all predictors
predictor_formula <- paste("y ~", paste(all_feats, collapse = " + "))
# Estimate the new MIDAS regression model using all predictors
midas_model_multi <- midas_r(as.formula(predictor_formula), data = x_agg_feats, start = NULL)
# Display the summary of the new model
summary(midas_model_multi)


# ------------------------ PREDICTION (Out-of-sample) ------------------------
# Monthly validation observations
monthly_validation <- filter(data_all, freq == "month" & set == "validation")
View(monthly_validation)
# Weekly validation observations: 
weekly_validation  <- filter(data_all, set == "validation") 
View(weekly_validation)

# Aggregate all weekly validation predictors to match the monthly frequency
x_agg_validation <- lapply(all_feats, function(feat) {
  sapply(seq(1, nrow(weekly_validation), by = 4), function(i) mean(weekly_validation[i:(i+3), feat], na.rm = TRUE))
})
# Convert the list of aggregated validation predictors to a data frame
x_agg_validation <- as.data.frame(x_agg_validation)
colnames(x_agg_validation) <- all_feats

# Predict the dependent variable using the validation data
validation_predictions <- predict(midas_model_multi, newdata = x_agg_validation)
validation_predictions <- as.numeric(validation_predictions)

# Create a dataframe with actual and predicted values for validation
validation_results_df <- data.frame(
  index = monthly_validation$X,
  actual = monthly_validation$ipc_all,
  predicted = validation_predictions
)

# View the validation results dataframe
View(validation_results_df)

# Compute Mean Squared Error (MSE) for validation
validation_mse <- mean((validation_results_df$actual - validation_results_df$predicted)^2, na.rm = TRUE)
print(paste("Validation Mean Squared Error:", validation_mse))

# Compute R2 score for validation
validation_r2 <- 1 - (sum((validation_results_df$actual - validation_results_df$predicted)^2, na.rm = TRUE) / 
                      sum((validation_results_df$actual - mean(validation_results_df$actual, na.rm = TRUE))^2, na.rm = TRUE))
print(paste("Validation R2 Score:", validation_r2))






# ------------------------ PREDICTION (In-sample) ------------------------
# Predict in-sample values
predicted_values <- predict(midas_model_multi)
predicted_values <- as.numeric(predicted_values)

# Create a dataframe with actual and predicted values
results_df <- data.frame(
  index = monthly_data$X,  
  actual = monthly_data$ipc_all,
  predicted = predicted_values
)

# View the resulting dataframe
View(results_df)

# Compute Mean Squared Error (MSE)
mse <- mean((results_df$actual - results_df$predicted)^2, na.rm = TRUE)
print(paste("Mean Squared Error:", mse))
# Compute R2 score
r2 <- 1 - (sum((results_df$actual - results_df$predicted)^2, na.rm = TRUE) / sum((results_df$actual - mean(results_df$actual, na.rm = TRUE))^2, na.rm = TRUE))
print(paste("R2 Score:", r2))
