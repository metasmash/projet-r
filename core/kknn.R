#--------------------------------------#
# ACTIVATION DES LIRAIRIES NECESSAIRES #
#--------------------------------------#
attach(input[[1]])
needs(kknn)
needs(ROCR)

#-------------------------#
# PREPARATION DES DONNEES #
#-------------------------#

setwd('data')
data <- read.csv("dataset.csv", header = TRUE, sep = ",", dec = ".", stringsAsFactors = T)
data_new <- read.csv("predict.csv", header = TRUE, sep = ",", dec = ".", stringsAsFactors = T)
setwd('../images')
data_shuffle <- data[sample(seq_along(data[, 1])),]

data_ea <- data_shuffle[1:800,]
data_et <- data_shuffle[801:1200,]

jpeg('kknn.jpg')

#---------------------#
# K-NEAREST NEIGHBORS #
#---------------------#

test_knn <- function(arg1, arg2, arg3){
  # Apprentissage et test simultanes du classifeur de type k-nearest neighbors
  knn <- kknn(default~., data_ea, data_et, k = arg1, distance = arg2)

  # Courbe ROC
  knn_pred <- prediction(knn$prob[,2], data_et$default)
  knn_perf <- performance(knn_pred,"tpr","fpr")
  plot(knn_perf, main = "Classifeurs K-plus-proches-voisins kknn()", add = FALSE, col = arg3)
    dev.off()

  # Calcul de l'AUC et affichage par la fonction cat()
  knn_auc <- performance(knn_pred, "auc")

  confusionMatrix <- as.matrix(
    table(data_et$default, knn$fitted.values),
  )

  #this is a security to ensure a 2 dimensionnal confusion matrix
  if(length(confusionMatrix[1,])==1){
    confusionMatrix <- cbind(c(confusionMatrix[1,],0), c(confusionMatrix[2,],0))
  }

  knn.new <- kknn(default~., data_ea, data_new, k = arg1, distance = arg2)

  data_new$prediction <- knn.new$fitted.values
  data_new$probability <- knn.new$prob[,1]

  data_et$prediction <- knn$fitted.values
  data_et$probability <- knn$prob[,1]

  return(list("AUC"=as.character(attr(knn_auc, "y.values")),
              "dataEtPrediction"=data_et,
              "dataNewPrediction"=data_new,
              "confusionMatrix"=
                list("predictedPositive"=confusionMatrix[1,]
                  ,"predictedNegative"=confusionMatrix[2,])
  ))

}

test_knn(arg1,arg2,arg3)