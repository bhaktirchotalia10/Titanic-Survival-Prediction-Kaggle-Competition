# Titanic-Survival-Prediction-Kaggle-Competition

**Project Overview**
The Titanic disaster of 1912 is one of the most infamous shipwrecks in history. Onboard were 2,224 passengers and crew, but only 712 survived. In this challenge, we aim to predict which passengers were more likely to survive using passenger data (name, age, gender, socio-economic class, etc.).

The analysis explores correlations between survival and these factors and implements machine learning models for the prediction task.

**Objective**
To build a predictive model that answers the question: "What sorts of people were more likely to survive?"

**Dataset Information**
In this competition, two datasets are provided:  
  - train.csv: A dataset of 891 passengers, including the survival status for each passenger (the "ground truth").
  - test.csv: A dataset of 418 passengers, without the survival status. Your task is to predict whether each of these passengers survived.

**Passenger features include:**

  - Pclass: Ticket class
  - Name: Name of the passenger
  - Sex: Gender of the passenger
  - Age: Age of the passenger
  - SibSp: Number of siblings/spouses aboard
  - Parch: Number of parents/children aboard
  - Ticket: Ticket number
  - Fare: Passenger fare
  - Cabin: Cabin number
  - Embarked: Port of Embarkation (C = Cherbourg, Q = Queenstown, S = Southampton)

# Modeling Process

**Feature Engineering**

  - Surname Extraction: Surnames were extracted from passenger names to group family members.
  - Title Engineering: Titles were categorized into 'man', 'woman', and 'boy' based on the passenger's name and gender. Special handling was applied to identify children and women in the dataset.
  - Group Formation: Passengers were grouped by family using ticket numbers and surnames. Group survival rates were calculated to improve prediction accuracy, especially for woman-child groups.
  - Survival Prediction: Predictions were based on gender, class, group survival rates, and the extracted features.

**Key Steps:**

1. Data preparation and merging of training and test datasets.
2. Engineering features such as Surname, GroupId, and Title.
3. Performing cross-validation to optimize model performance.
4. Running predictions using group and survival insights.

**Results & Plots:**

The following plots illustrate the analysis and key findings of the woman-child groups:

1. Pclass: Survival rates based on class. Third-class passengers had lower survival rates.
2. Age: Young children had a higher chance of survival, especially boys traveling with families.
3. Embarked: Passengers who boarded at Southampton had the lowest survival rate.
4. Cabin: The cabin letter (if available) was explored for survival patterns.

**Submission:**

The best model submission resulted in a Kaggle score of **0.81339**

The model was evaluated using **25 trials of 10-fold cross-validation**, yielding an average **accuracy of over 81%.**
