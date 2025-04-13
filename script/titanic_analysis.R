### Loading the Dataset

library(readxl)
titanic_ds <- read_excel("titanic_ds.xls")
str(titanic_ds)


# -------------------------------------------------
# Cleaning the Dataset
# -------------------------------------------------

library(Amelia)
missmap(titanic_ds, col = c("red", "green"))

library(tidyverse)
selected_titanic <- titanic_ds %>%
  select(age, pclass, sex, survived, embarked, home.dest, fare, parch, sibsp)

selected_titanic$FamilySize <- selected_titanic$sibsp + selected_titanic$parch + 1
str(selected_titanic)

selected_titanic$FareCategory <- cut(selected_titanic$fare, 
                                     breaks = c(0, 10, 20, 50, 100, Inf), 
                                     labels = c("Lowest", "Lower Middle", 
                                                "Upper Middle", "Higher", 
                                                "Highest"))
str(selected_titanic)

selected_titanic <- selected_titanic %>% 
  select(-fare, -parch, -sibsp)

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

selected_titanic <- selected_titanic %>% 
  rename(
    Class = pclass,
    Destination = home.dest
  )

selected_titanic <- selected_titanic %>% 
  rename_all(~str_to_title(.))

missmap(selected_titanic, col = c("red", "green"))
selected_titanic <- drop_na(selected_titanic)

missmap(selected_titanic, col = c("red", "green"))

# -------------------------------------------------
# Univariate Analysis: Analyzing and Visualizing Individual Variables in Titanic Dataset
# -------------------------------------------------

## Fare Category Distribution
fare_count <- table(selected_titanic$Farecategory)
print(fare_count)

summary_fare <- selected_titanic %>%
  group_by(Farecategory) %>%
  summarize(n = n()) %>%
  mutate(Fpercentage = n / sum(n) * 100)

ggplot(summary_fare, aes(x = "", y = n, fill = Farecategory)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar(theta = "y") +
  theme_void() +
  labs(title = "Fare Distribution in Titanic Dataset", fill = "Fare Category") +
  geom_text(aes(label = paste0(round(Fpercentage, 2), "%")),
            position = position_stack(vjust = 0.5), color = "white")
ggsave("Fare Distribution_titanic_dataset.png", width = 10, height = 8)


## Gender Distribution
gender_count <- table(selected_titanic$Sex)
gender_count

summary_gender <- selected_titanic %>%
  group_by(Sex) %>%
  summarize(n = n()) %>%
  mutate(Gpercentage = n / sum(n) * 100)

ggplot(summary_gender, aes(x = "", y = n, fill = Sex)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar(theta = "y") +
  theme_void() +
  labs(title = "Gender Distribution in Titanic Dataset", fill = "Gender") +
  geom_text(aes(label = paste0(round(Gpercentage, 2), "%")),
            position = position_stack(vjust = 0.5), color = "white")
ggsave("Gender_distribution_titanic.png", width = 10, height = 8)

##  Age Distribution
age_count <- table(selected_titanic$Age)
age_count

pie(age_count, main = "Age Distribution in Titanic Dataset", 
    labels = paste(round(age_count/sum(age_count) * 100, 2), "%", sep = ""), 
    col = rainbow(length(age_count)))
legend("topright", names(age_count), cex = 0.8, fill = rainbow(length(age_count)))

## Port of Embarkation
embark_count <- table(selected_titanic$Embarked)
embark_count

ggplot(selected_titanic, aes(x = Embarked, fill = Embarked)) + 
  geom_bar() + 
  theme_classic() + 
  labs(x = "Port of Embarkation", y = "Number of Passengers",
       title = "Port of Embarkation Distribution in Titanic Dataset")
ggsave("embarkation_distribution.png", width = 10, height = 8)

## Class Distribution
class_count <- table(selected_titanic$Class)
class_count

png("class_distribution.png", width = 1000, height = 800)
barplot(class_count,
        main = "Passengers' Ticket Class Distribution in Titanic Dataset", 
        xlab = "Ticket Class", 
        ylab = "Number of Passengers", 
        col = "skyblue")


## Survival Distribution
survive_count <- table(selected_titanic$Survived)
survive_count

summary_survived <- selected_titanic %>%
  group_by(Survived) %>%
  summarize(n = n()) %>%
  mutate(Spercentage = n / sum(n) * 100)

ggplot(summary_survived, aes(x = "", y = n, fill = Survived)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar(theta = "y") +
  theme_void() +
  labs(title = "Passengers' Survival Distribution in Titanic Dataset", 
       fill = "Survived") +
  geom_text(aes(label = paste0(round(Spercentage, 2), "%")),
            position = position_stack(vjust = 0.5), color = "white") +
  scale_fill_manual(values = c("No" = "red", "Yes" = "darkgreen"))
ggsave("Survival_distribution_titanic.png", width = 10, height = 8)

## Destination Distribution
library(knitr)
destination_count <- table(selected_titanic$Destination)
kable(destination_count)

summary_destination <- selected_titanic %>%
  group_by(Destination) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  head(10)

ggplot(summary_destination, aes(x = Destination, y = count, fill = count)) +
  geom_tile() +
  labs(title = "Top 10 Destination Distribution of Passengers in Titanic Dataset", 
       x = "Destination", y = "Number of Passengers") +
  theme_minimal() +
  theme( axis.text.x = element_text(angle = 45, hjust = 1))
ggsave("Destination_distribution_titanic.png", width = 10, height = 8)


# -------------------------------------------------
# Bivariate BIVARIATE ANALYSIS: Analysing and Visualizing Relationships Between Survival Rate and other Variables in Titanic Dataset
# -------------------------------------------------

## Survival Rate by Fare
summary_sf <- selected_titanic %>%
  group_by(Farecategory, Survived) %>%
  summarise(survival_rate = n()) %>%
  mutate(sfPercentage = survival_rate / sum(survival_rate) * 100)

ggplot(summary_sf, aes(x = Farecategory, y = sfPercentage, fill = Survived))+
  geom_bar(stat = "identity", position = "stack") +
  labs(title = "Survival Rate by Fare Category in Titanic Dataset", x = "Fare Category", y = "Survival Rate(%)") +
  scale_fill_manual(values = c("No" = "red", "Yes" = "darkgreen"))
ggsave("Survival_byfare_titanic.png", width = 10, height = 8)

## Survival Rate by Gender
summary_sg <- selected_titanic %>%
  group_by(Sex, Survived) %>%
  summarise(count = n()) %>%
  mutate(sgPercentage = count / sum(count) * 100)

ggplot(summary_sg, aes(x = Sex, y = sgPercentage, fill = Survived)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(title = "Survival Rate by Gender in Titanic Dataset", x = "Gender", y = "Survival Rate(%)") +
  theme_classic() +
  scale_fill_manual(values = c("No" = "red", "Yes" = "darkgreen"))
ggsave("Survival_bygender_titanic.png", width = 10, height = 8)

## Survival Rate by Age
summary_sa <- selected_titanic %>%
  group_by(Age, Survived) %>%
  summarise(count = n()) %>%
  mutate(saPercentage = count / sum(count) * 100)

ggplot(summary_sa, aes(x = Age, y = saPercentage, fill = Survived))+
  geom_bar(stat = "identity", position = "dodge")+
  labs(title = "Survival Rate by Age in Titanic Dataset", x = "Age", y = "Survival Rate(%)", fill = "Survived")+
  theme_classic()+
  scale_fill_manual(values = c("No" = "red", "Yes" = "darkgreen"))
ggsave("Survival_byage_titanic.png", width = 10, height = 8)

## Survival Rate by Class
summary_sc <- selected_titanic %>%
  group_by(Class, Survived) %>%
  summarise(count = n()) %>%
  mutate(scPercentage = count / sum(count) * 100)

ggplot(summary_sc, aes(x = Class, y = scPercentage, fill = Survived)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(title = "Survival Rate by Ticket Class in Titanic Dataset", x = "Ticket Class", y = "Survival Rate (%)") +
  theme_minimal()
ggsave("Survival_byclass_titanic.png", width = 10, height = 8)

## Survival Rate by Port of Embarkation
summary_sp <- selected_titanic %>%
  group_by(Embarked, Survived) %>%
  summarise(count = n()) %>%
  mutate(spPercentage = count / sum(count) * 100)

ggplot(summary_sp, aes(x = Embarked, y = spPercentage, fill = Survived))+
  geom_bar(stat = "identity", position = "dodge")+
  labs(title = "Survival Rate by Port of Embarkation in Titanic Dataset", x = "Port of Embarkation", y = "Survival Rate")+
  theme_classic()+
  scale_fill_manual(values = c("No" = "red", "Yes" = "darkgreen"))
ggsave("Survival_byport_titanic.png", width = 10, height = 8)
