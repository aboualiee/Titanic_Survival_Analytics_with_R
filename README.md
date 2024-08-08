# Data_Analytics_with_R
---
title: "Wrangling and Visualizing Data with R"
author: "Abu Ali"
date: "`r Sys.Date()`"
output:
  pdf_document: default
  html_document: default
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## The Titanic Dataset

we will use R packages to explore the Titanic dataset and visualize key patterns and insights, and their relations to the survival rate of the passengers. 

You can download the the titanic dataset here: https://www.kaggle.com/datasets/yasserh/titanic-dataset 


### LOADING THE DATASET:
```{r dataset}
library(readxl)
titanic_ds <- read_excel("titanic_ds.xls")
str(titanic_ds)
```

### CLEANING THE DATASET:

#### 1. Check for missing values
```{r missing values, echo=TRUE}
library(Amelia)
missmap(titanic_ds, col = c("red", "green"))
```

Note that you can add `echo = FALSE` parameter to the code chunk to prevent printing of the R code that generated the plot.

#### 2. Select relevant columns for the analysis 

```{r select columns}
library(tidyverse)
selected_titanic <- titanic_ds %>%
  select (age, pclass, sex, survived, embarked, home.dest, fare, parch, sibsp)
```

#### 3. Merge columns parch and sibsp to create a new column, FamilySize
```{r FamilySize}
selected_titanic$FamilySize <- selected_titanic$sibsp + selected_titanic$parch + 1
str(selected_titanic)
```



#### 4. Categorize the fare column and assign label to each category
```{r FareCategory}
selected_titanic$FareCategory <- cut(selected_titanic$fare, 
                                   breaks = c(0, 10, 20, 50, 100, Inf), 
                                   labels = c("Lowest", "Lower Middle", 
                                        "Upper Middle", "Higher", "Highest"))
str(selected_titanic)
```

#### 5. Remove the columns that are being merged to form new columns
```{r Remove irrelevant columns}
selected_titanic <- selected_titanic %>% 
  select(-fare, -parch, -sibsp)
```

#### 6. Change the values of columns pclass, survived, and embarked
```{r change columns values}
selected_titanic <- selected_titanic %>%
  mutate(
    survived = ifelse(survived == 0, "No", "Yes"),
    age = ifelse(age >= 18, "Adult", "Child"),
    pclass = case_when(
      pclass == 1 ~ "1st",
      pclass == 2 ~ "2nd",
      pclass == 3 ~ "3rd"
    ),
    
    embarked = case_when(
      embarked == "C" ~ "Cherbourg",
      embarked == "Q" ~ "Queenstown",
      embarked == "S" ~ "Southampton"
    )
  )
```

#### 7. Change the name of column pclass to Class, and home.dest to Destination
```{r change names of columns}
selected_titanic <- selected_titanic %>% 
  rename(
    Class = pclass,
    Destination = home.dest
  )
```

#### 8. Capitalize the initials of all the columns name
```{r capitalized the initials of the columns}
selected_titanic <- selected_titanic %>% 
  rename_all(~str_to_title(.))
```

#### 9. Check for missing values again
```{r check missing values}
missmap(selected_titanic, col = c("red", "green"))
```

#### 10. Drop all the missing values from the dataset

```{r drop missing values}
selected_titanic <- drop_na(selected_titanic)
```

```{r cleaned missingnessmap, echo=FALSE}
missmap(selected_titanic, col = c("red", "green"))
```

### EXPLORING THE DATASET:

