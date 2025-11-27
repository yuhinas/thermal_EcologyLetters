# --------------------------------------------------------------------
# 1. Load Required Libraries
# --------------------------------------------------------------------
library(magrittr)   # For piping functionality (e.g., %>%)
library(dplyr)      # For data manipulation and piping
library(car)        # For type II ANOVA
library(ggplot2)    # For data visualization
# --------------------------------------------------------------------
# 2. Data Loading and Preparation
# --------------------------------------------------------------------

# Read time-series body temperature, behavior, and individual data
data_t <- read.csv("data/body_temp.csv")
data_b <- read.csv("data/behavior.csv")
data_i <- read.csv("data/individual.csv")

# --- Behavior Variable Construction ---

# Calculate total conflict time (sum of columns 42-46)
data_b$conflict <- apply(data_b[, 42:46], 1, sum)

# Calculate total cooperative investment time (sum of columns 52-56)
data_b$investment <- apply(data_b[, 52:56], 1, sum)

# Calculate Conflict/Investment ratio (Conflict Index)
data_b$conflict_invest <- data_b$conflict / data_b$investment
# Handle cases where investment is zero (resulting in NA)
data_b$conflict_invest[which(data_b$investment == 0)] <- NA

# --- Data Subsetting and Merging  ---

# Calculate mean temperature for the first half of the night
temp <- data_t %>% 
  group_by(nm) %>% 
  subset(Time_Relative_sf <= 5 * 3600) %>% 
  summarise(mean_temp = mean(Tb.Tc, na.rm = TRUE))

# Select only nm and treat from individual data for merging
data_i <- data_i[, c("nm", "treat")]

# Merge temperature, individual (treat), and behavior data
data1 <- merge(data_i, temp) %>% merge(., data_b[, c("nm", "conflict", "investment", "conflict_invest")])

# Split the merged dataset by treatment group (M6=Control, M7=Blowfly)
data1_m <- subset(data1, data1$treat == "maggot") # Blowfly group
data1_c <- subset(data1, data1$treat == "control") # Control group

# --------------------------------------------------------------------
# 3. Model Fitting (M6 & M7)
# M6/C1: Control Group Model
# M7/M1: Blowfly Group Model
# Response: mean_temp
# Predictors: investment (cooperation) + conflict_invest (conflict index)
# --------------------------------------------------------------------

# M6 (Control group model, used for Fig 4A, 4B)
c1 <- lm(mean_temp ~ investment + conflict_invest, data = data1_c)
summary(c1)
Anova(c1, type=2) # Get F value and p value

# M7 (Blowfly group model, used for Fig 4C, 4D)
m1 <- lm(mean_temp ~ investment + conflict_invest, data = data1_m)
summary(m1)
Anova(m1, type=2) # Get F value and p value

# --------------------------------------------------------------------
# 4. Visualization (Figure 4A - 4D)
# Plotting Partial Regression Effects
# --------------------------------------------------------------------

# --- Figure 4A: Control, Cooperation Effect (Predicting mean_temp from investment) ---

# Create prediction data frame: Vary 'investment' while holding 'conflict_invest' constant at its mean
xv_4A <- data.frame(
  investment = seq(min(data1_c$investment, na.rm = T), max(data1_c$investment, na.rm = T), length.out = 100),
  conflict_invest = mean(data1_c$conflict_invest, na.rm = TRUE)
)
# Get predicted values and 95% CI (fit +/- 1.96*SE)
yv_4A <- data.frame(predict(c1, xv_4A, type = "response", se.fit = TRUE), xv_4A) 
yv_4A$upper <- yv_4A$fit + 1.96 * yv_4A$se.fit
yv_4A$lower <- yv_4A$fit - 1.96 * yv_4A$se.fit

figure_4A <- ggplot(data = yv_4A, aes(x = investment, y = fit)) +
  geom_line(linewidth = 1) +
  geom_point(data = data1_c, aes(x = investment, y = mean_temp), shape = 1, colour = "dimgrey") + 
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "grey", alpha = 0.5) + 
  theme_classic() +
  theme(text = element_text(size = 21)) +
  labs(x = "Total cooperative investment (s)", y = "Relative body temperature (°C)") +
  coord_cartesian(ylim = c(-1, 5), expand = TRUE)

print(figure_4A)


# --- Figure 4B: Control, Conflict Index Effect (Predicting mean_temp from conflict_invest) ---

# Create prediction data frame: Vary 'conflict_invest' while holding 'investment' constant at its mean
xv_4B <- data.frame(
  investment = mean(data1_c$investment, na.rm = TRUE),
  conflict_invest = seq(min(data1_c$conflict_invest, na.rm = T), max(data1_c$conflict_invest, na.rm = T), length.out = 100)
)
# Get predicted values and 95% CI
yv_4B <- data.frame(predict(c1, xv_4B, type = "response", se.fit = TRUE), xv_4B) 
yv_4B$upper <- yv_4B$fit + 1.96 * yv_4B$se.fit
yv_4B$lower <- yv_4B$fit - 1.96 * yv_4B$se.fit

figure_4B <- ggplot(data = yv_4B, aes(x = conflict_invest, y = fit)) +
  geom_line(linewidth = 1) +
  geom_point(data = data1_c, aes(x = conflict_invest, y = mean_temp), shape = 1, colour = "dimgrey") + 
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "grey", alpha = 0.5) +
  theme_classic() +
  theme(text = element_text(size = 21)) +
  labs(x = "Number of social conflict (per unit time)", y = "Relative body temperature (°C)") + 
  coord_cartesian(ylim = c(-1, 5), expand = TRUE)

print(figure_4B)


# --- Figure 4C: Blowfly, Cooperation Effect (Predicting mean_temp from investment) ---

# Create prediction data frame: Vary 'investment' while holding 'conflict_invest' constant at its mean
xv_4C <- data.frame(
  investment = seq(min(data1_m$investment, na.rm = T), max(data1_m$investment, na.rm = T), length.out = 100),
  conflict_invest = mean(data1_m$conflict_invest, na.rm = TRUE)
)
# Get predicted values and 95% CI
yv_4C <- data.frame(predict(m1, xv_4C, type = "response", se.fit = TRUE), xv_4C) 
yv_4C$upper <- yv_4C$fit + 1.96 * yv_4C$se.fit
yv_4C$lower <- yv_4C$fit - 1.96 * yv_4C$se.fit

figure_4C <- ggplot(data = yv_4C, aes(x = investment, y = fit)) +
  geom_line(linewidth = 1) +
  geom_point(data = data1_m, aes(x = investment, y = mean_temp), shape = 1, colour = "dimgrey") + 
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "grey", alpha = 0.5) + 
  theme_classic() +
  theme(text = element_text(size = 21)) +
  labs(x = "Total cooperative investment (s)", y = "Relative body temperature (°C)") +
  coord_cartesian(ylim = c(-1, 5), expand = TRUE)

print(figure_4C)


# --- Figure 4D: Blowfly, Conflict Index Effect (Predicting mean_temp from conflict_invest) ---

# Create prediction data frame: Vary 'conflict_invest' while holding 'investment' constant at its mean
xv_4D <- data.frame(
  investment = mean(data1_m$investment, na.rm = TRUE),
  conflict_invest = seq(min(data1_m$conflict_invest, na.rm = T), max(data1_m$conflict_invest, na.rm = T), length.out = 100) 
)
# Get predicted values
yv_4D <- data.frame(predict(m1, xv_4D, type = "response", se.fit = TRUE), xv_4D) 

figure_4D <- ggplot(data = yv_4D, aes(x = conflict_invest, y = fit)) +
  geom_line(linewidth = 1,linetype = "dashed") +
  geom_point(data = data1_m, aes(x = conflict_invest, y = mean_temp), shape = 1, colour = "dimgrey") + 
  theme_classic() +
  theme(text = element_text(size = 21)) +
  labs(x = "Number of social conflict (per unit time)", y = "Relative body temperature (°C)") +
  coord_cartesian(ylim = c(-1, 5), expand = TRUE)


print(figure_4D)
