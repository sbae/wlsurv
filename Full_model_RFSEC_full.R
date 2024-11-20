# Load libraries and source required scripts
# setwd("/gpfs/home/kantap01/wml/Final")

source("setup.R")

train_set <- readRDS("train_set.rds")
# test_set <- readRDS("test_set.rds")    # No need for now
#################### RANDOM FOREST SURVIVAL ################################

# Tell RF to use 4 cores
ncore <- 4
options(rf.cores=ncore, mc.cores=ncore)

# # Use a 10% random subset for tuning
# samp_prop <- 0.1
# tune_subset <- sample(nrow(train_set), nrow(train_set)*samp_prop)
# train_set_small <- train_set[tune_subset,]

# # Perform hyperparameter tuning
# system.time( # Just adding a stopwatch
# tune_results <- tune(
#   formula = as.formula(paste("Surv(X_t, X_d) ~", paste(variables_0, collapse = " + "))), 
#   data = train_set_small,
#   ntreeTry = 750,   # Please change this to 750
#   nodesizeTry = c(5, 10, 15, 20, 25, 30, 35),  
#   mtryStart = 5,  
#   stepFactor = 1.2,  # Smaller step size for finer tuning
#   improve = 1e-3,  # Stricter improvement criterion
#   maxIter = 30,  # Increase max iterations for a more comprehensive search
#   trace = TRUE,
# )
# )

# # Extract the best parameters from tuning results
# best_params <- tune_results$optimal
# print("Best Parameters from Tuning:")
# print(best_params)

# Train the final model with the best hyperparameters using parallel processing
system.time( # Just adding a stopwatch
rfs_full <- rfsrc(
  formula = as.formula(paste("Surv(X_t, X_d) ~", paste(variables_0, collapse = " + "))),
  data = train_set,
  ntree = 750,  # Please change this to 750
  nodesize = 5,   # just use the results from the previous run
  mtry = 8,
  # mtry = best_params["mtry"],
  # nodesize = best_params["nodesize"],
  na.action = "na.impute",
# Let's also try some tricks from https://www.randomforestsrc.org/articles/speedup.html
  importance = 'none', 
  ntime=100,
  perf.type='none' ### This turns of the internal calculation for C-stat. We do this later anyways, correct?
)
)

# Check the memory status in MB
sapply(ls(), function(x) object.size(get(x))/2^20)

# Save and print the results
saveRDS(rfs_full, "rfs_full_model_0.rds")

#### I set importance="none" to speed things up. Now we will need to run a prediction on the training set to make this work.
# var_importance <- vimp(rfs_full)
# top_variables <- sort(var_importance, decreasing = TRUE)
# print("Top Variables by Importance:")
# print(top_variables)
