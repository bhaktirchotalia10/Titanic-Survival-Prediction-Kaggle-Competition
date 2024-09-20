# Read data
test <- read.csv("C:\\Users\\bhakt\\Desktop\\DAmore McKim School of Business\\Semester 1\\Foundation of Data Analysis\\Kaggle Competition\\test.csv", stringsAsFactors = FALSE)
train <- read.csv("C:\\Users\\bhakt\\Desktop\\DAmore McKim School of Business\\Semester 1\\Foundation of Data Analysis\\Kaggle Competition\\train.csv", stringsAsFactors = FALSE)

# Initialize 'Survived' column in the test set and combine data
test$Survived <- NA
data <- rbind(train, test)

# Extract Surname and create GroupId
data$Surname <- substring(data$Name, 0, regexpr(',', data$Name) - 1)
data$GroupId <- paste(data$Surname, data$Pclass, sub('.$', 'X', data$Ticket), data$Fare, data$Embarked, sep = '-')

# Select specific rows and columns
selected_data <- data[c(195, 1067, 59, 473, 1142), c('Name', 'GroupId')]


# Engineer titles
data$Title <- 'man'
data$Title[data$Sex == 'female'] <- 'woman'
data$Title[grep('Master', data$Name)] <- 'boy'

# Color variable is used in plots below
data$Color <- data$Survived

# Engineer "woman-child-groups"
data$GroupId[data$Title == 'man'] <- 'noGroup'
data$GroupFreq <- ave(1:1309, data$GroupId, FUN = length)
data$GroupId[data$GroupFreq <= 1] <- 'noGroup'
data$TicketId <- paste(data$Pclass, sub('.$', 'X', data$Ticket), data$Fare, data$Embarked, sep = '-')

count <- 0
# Add nannies and relatives to groups
for (i in which(data$Title != 'man' & data$GroupId == 'noGroup')) {
  data$GroupId[i] <- data$GroupId[data$TicketId == data$TicketId[i]][1]
  if (data$GroupId[i] != 'noGroup') {
    # Color variable is used in plots below
    if (is.na(data$Survived[i])) data$Color[i] = 5
    else if (data$Survived[i] == 0) data$Color[i] = -1
    else if (data$Survived[i] == 1) data$Color[i] = 2
    count <- count + 1
  }
}
cat(sprintf('We found %d nannies/relatives and added them to groups.\n', count))


install.packages("gridExtra")
library(ggplot2)
library(gridExtra)

# Extract GroupName from GroupId
data$GroupName <- substring(data$GroupId, 0, regexpr('-', data$GroupId) - 1)

# Assign colors based on conditions
data$Color[is.na(data$Color) & data$Title == 'woman'] <- 3
data$Color[is.na(data$Color) & data$Title == 'boy'] <- 4

# Get unique GroupIds and order them
x <- data$GroupId[data$GroupId != 'noGroup']
x <- unique(x)
x <- x[order(x)]

# Prepare data for plotting
plotData <- list()
g <- list()

for (i in 1:3) {
  plotData[[i]] <- data[data$GroupId %in% x[(27 * (i - 1)) + 1:27], ]
}

for (i in 1:3) {
  g[[i]] <- ggplot(data = plotData[[i]], aes(x = 0, y = factor(GroupName))) +
    geom_dotplot(dotsize = 0.9, binwidth = 1, binaxis = 'y', method = "histodot", stackgroups = T,
                 aes(fill = factor(Color), color = Title)) +
    scale_color_manual(values = c('gray70', 'blue', 'gray70'), limits = c('man', 'boy', 'woman')) +
    scale_fill_manual(values = c('#BB0000', '#FF0000', '#009900', '#00EE00', 'gray70', 'gray70', 'white'),
                      limits = c('0', '-1', '1', '2', '3', '4', '5')) +
    scale_y_discrete(limits = rev(levels(factor(plotData[[i]]$GroupName)))) +
    theme(axis.title.x = element_blank(), axis.title.y = element_blank(),
          axis.text.x = element_blank(), axis.ticks.x = element_blank(),
          legend.position = 'none')
}

# Arrange the plots
grid.arrange(g[[1]], g[[2]], g[[3]], nrow = 1,
             top = 'All 80 woman-child-groups in the test and training datasets combined (228 passengers).
             Red = deceased female or boy, Green = survived, White or Gray = unknown survival,
             White or LightGreen or LightRed = different surname same ticket, Blue outline = boy')
data$Survived <- factor(data$Survived)
data$CabinLetter <- substring(data$Cabin, 0, 1)

g1 <- ggplot(data = data[data$GroupId != 'noGroup' & !is.na(data$Survived), ]) +
  geom_bar(stat = 'count', aes(x = Pclass, fill = Survived))

g2 <- ggplot(data = data[data$GroupId != 'noGroup' & !is.na(data$Survived) & !is.na(data$Age), ]) +
  geom_histogram(bins = 20, aes(x = Age, fill = Survived))

g3 <- ggplot(data = data[data$GroupId != 'noGroup' & !is.na(data$Survived), ]) +
  geom_bar(stat = 'count', aes(x = Embarked, fill = Survived))

g4 <- ggplot(data = data[data$GroupId != 'noGroup' & !is.na(data$Survived), ]) +
  geom_bar(stat = 'count', aes(x = CabinLetter, fill = Survived))

grid.arrange(g1, g2, g3, g4, nrow = 2, top = 'Analysis of training set\'s 156 Woman-Child-Group passengers')


# Engineer titles on the training set
train$Title <- 'man'
train$Title[train$Sex == 'female'] <- 'woman'
train$Title[grep('Master', train$Name)] <- 'boy'

# Perform 25 trials of 10-fold cross-validation
trials <- 25
sum_accuracy <- 0

for (j in 1:trials) {
  x <- sample(1:890)
  s <- 0
  for (i in 0:9) {
    # Engineer "woman-child-groups"
    train$Surname <- substring(train$Name, 0, regexpr(",", train$Name) - 1)
    train$GroupId <- paste(train$Surname, train$Pclass, sub('.$', 'X', train$Ticket), train$Fare, train$Embarked, sep = '-')
    train$GroupId[train$Title == 'man'] <- 'noGroup'
    train$GroupFreq <- ave(1:891, train$GroupId, FUN = length)
    train$GroupId[train$GroupFreq <= 1] <- 'noGroup'
    # Add nannies and relatives to groups.
    train$TicketId <- paste(train$Pclass, sub('.$', 'X', train$Ticket), train$Fare, train$Embarked, sep = '-')
    for (k in which(train$Title != 'man' & train$GroupId == 'noGroup')) {
      train$GroupId[k] <- train$GroupId[train$TicketId == train$TicketId[k] & train$PassengerId != train$PassengerId[k]][1]
    }
    train$GroupId[is.na(train$GroupId)] <- 'noGroup'
    train$GroupFreq <- ave(1:891, train$GroupId, FUN = length)
    # Calculate training subset's group survival rate
    train$GroupSurvival <- NA
    train$GroupSurvival[-x[1:89 + i * 89]] <- ave(train$Survived[-x[1:89 + i * 89]], train$GroupId[-x[1:89 + i * 89]])
    # Calculate testing subset's group survival rate from the training set's rate
    for (k in x[1:89 + i * 89]) {
      train$GroupSurvival[k] <- train$GroupSurvival[which(!is.na(train$GroupSurvival) & train$GroupId == train$GroupId[k])[1]]
      if (is.na(train$GroupSurvival[k])) train$GroupSurvival[k] <- ifelse(train$Pclass[k] == 3, 0, 1)
    }
    # Apply gender model plus WCG
    train$predict <- 0
    train$predict[train$Title == 'woman'] <- 1
    train$predict[train$Title == 'boy' & train$GroupSurvival == 1] <- 1
    train$predict[train$Title == 'woman' & train$GroupSurvival == 0] <- 0
    c <- sum(abs(train$predict[x[1:89 + i * 89]] - train$Survived[x[1:89 + i * 89]]))
    s <- s + c
  }
  cat(sprintf("Trial %d has 10-fold CV accuracy = %f\n", j, 1 - s / 890))
  sum_accuracy <- sum_accuracy + 1 - s / 890
}

# Print the average accuracy from trials
cat(sprintf("Average 10-fold CV accuracy from %d trials = %f\n", trials, sum_accuracy / trials))

# Initialize GroupSurvival as NA
data$GroupSurvival <- NA

# Convert Survived to numeric
data$Survived <- as.numeric(as.character(data$Survived))

# Calculate GroupSurvival for the training set (rows 1 to 891)
data$GroupSurvival[1:891] <- ave(data$Survived[1:891], data$GroupId[1:891])

# Calculate GroupSurvival for the testing set (rows 892 to 1309)
for (i in 892:1309)
  data$GroupSurvival[i] <- data$GroupSurvival[which(data$GroupId == data$GroupId[i])[1]]

# Assign default values for missing GroupSurvival based on Pclass
data$GroupSurvival[is.na(data$GroupSurvival) & data$Pclass == 3] <- 0
data$GroupSurvival[is.na(data$GroupSurvival) & data$Pclass != 3] <- 1

# Initialize Predict as 0
data$Predict <- 0

# Assign predictions based on conditions
data$Predict[data$Sex == 'female'] <- 1
data$Predict[data$Title == 'woman' & data$GroupSurvival == 0] <- 0
data$Predict[data$Title == 'boy' & data$GroupSurvival == 1] <- 1


# Display predicted survival outcomes for males
cat('The following 8 males are predicted to live\n')
print(data[data$Sex == 'male' & data$Predict == 1 & data$PassengerId > 891, c('Name', 'Title')])

# Display predicted non-survival outcomes for females
cat('The following 14 females are predicted to die\n')
print(data[data$Sex == 'female' & data$Predict == 0 & data$PassengerId > 891, c('Name', 'Title')])

# Display predictions for the remaining passengers
cat('The remaining 258 males are predicted to die\n')
cat('and the remaining 138 females are predicted to live\n')

# Create a submission file for the predictions
submit <- data.frame(PassengerId = 892:1309, Survived = data$Predict[892:1309])

# Write the submission file to a CSV
write.csv(submit, 'BhaktiSubmission10.csv', row.names = FALSE)
