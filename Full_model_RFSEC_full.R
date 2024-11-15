# Load libraries and source required scripts
setwd("/gpfs/home/kantap01/wml/Final")

source("setup.R")

train_set <- readRDS("train_set.rds")
test_set <- readRDS("test_set.rds")
#################### RANDOM FOREST SURVIVAL ################################

# Perform hyperparameter tuning
tune_results <- tune(
  formula = as.formula(paste("Surv(X_t, X_d) ~", paste(variables_0, collapse = " + "))), 
  data = train_set,
  ntreeTry = 20,   # Please change this to 750
  nodesizeTry = c(5, 10, 15, 20, 25, 30, 35),  
  mtryStart = 5,  
  stepFactor = 1.2,  # Smaller step size for finer tuning
  improve = 1e-3,  # Stricter improvement criterion
  maxIter = 30,  # Increase max iterations for a more comprehensive search
  trace = TRUE,
)

# Extract the best parameters from tuning results
best_params <- tune_results$optimal
print("Best Parameters from Tuning:")
print(best_params)

# Train the final model with the best hyperparameters using parallel processing
rfs_full <- rfsrc(
  formula = as.formula(paste("Surv(X_t, X_d) ~", paste(variables_0, collapse = " + "))),
  data = train_set,
  ntree = 20,  # Please change this to 750
  mtry = best_params["mtry"],
  nodesize = best_params["nodesize"],
  importance = TRUE, 
  na.action = "na.impute"
)

# Save and print the results
saveRDS(rfs_full, "rfs_full_model_0.rds")
var_importance <- rfs_full$importance
top_variables <- sort(var_importance, decreasing = TRUE)
print("Top Variables by Importance:")
print(top_variables)
