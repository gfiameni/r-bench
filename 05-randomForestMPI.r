#MPI based randomForest

suppressMessages(library(data.table))
suppressMessages(library(ROCR))
suppressMessages(library(doMPI))
suppressMessages(library(randomForest))

# Create and register an MPI cluster
cl <- startMPIcluster()
registerDoMPI(cl)

set.seed(123)

# Define a parallel randomForest function
rforest <- function(x, y=NULL, xtest=NULL, ytest=NULL, ntree=500, ...) {
  initWorkers <- function() library(randomForest)
  opts <- list(initEnvir=initWorkers)

  foreach(i=idiv(ntree, chunks=getDoParWorkers()),
          .combine='combine', .multicombine=TRUE, .inorder=FALSE,
          .options.mpi=opts) %dopar% {
    randomForest:::randomForest.default(x, y, xtest, ytest, ntree=i, ...)
  }
}

d_train <- as.data.frame(fread("train-0.1m.csv"))
d_test <- as.data.frame(fread("test.csv"))


system.time({
	X_train_test <-  model.matrix(dep_delayed_15min ~ ., data = rbind(d_train, d_test))
	X_train <- X_train_test[1:nrow(d_train),]
	X_test <- X_train_test[(nrow(d_train)+1):(nrow(d_train)+nrow(d_test)),]
})
dim(X_train)

# Execute rforest and then print the resulting model object
system.time({
	rfit <- rforest(X_train, as.factor(d_train$dep_delayed_15min))	
)}
print(rfit)

system.time({
	phat <- predict(rfit, newdata = X_test, type = "prob")[,"Y"]
})

rocr_pred <- prediction(phat, d_test$dep_delayed_15min)
performance(rocr_pred, "auc")

#gc()
#sapply(ls(),function(x) object.size(get(x))/1e6)

# Shutdown the cluster and quit
closeCluster(cl)
mpi.quit()