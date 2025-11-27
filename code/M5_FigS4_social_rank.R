# --------------------------------------------------------------------
# 1. Load Required Libraries 
# --------------------------------------------------------------------
library(magrittr)   # For piping functionality (e.g., %>%)
library(dplyr)      # For data manipulation and piping
library(emmeans)    # For estimated marginal means and post-hoc tests
library(ggplot2)    # For data visualization
library(ggsignif)   # For adding significance bars to ggplot
# --------------------------------------------------------------------
# 2. Data Loading and Preparation
# --------------------------------------------------------------------

# Read time-series body temperature data and individual-level data
data_t <- read.csv("data/body_temp.csv")
data_i <- read.csv("data/individual.csv")

# Convert the social rank variable (mi_hier) to a factor
data_i$mi_hier <- as.factor(data_i$mi_hier)


# --- Data Subsetting by Time and Treatment ---

# Calculate mean temperature for the FIRST HALF of the night (Time_Relative_sf <= 5*3600)
temp1 <- data_t %>% 
  group_by(nm) %>% 
  subset(Time_Relative_sf <= 5 * 3600) %>% 
  summarise(temp = mean(Tb.Tc, na.rm = TRUE))
data1 <- merge(data_i, temp1, by = "nm") # Merge with individual data

# Separate data1 into treatment groups
data1_m <- subset(data1, data1$treat == "maggot") # Blowfly group (M5-B1)
data1_c <- subset(data1, data1$treat == "control") # Control group (M5-C1)

# Calculate mean temperature for the SECOND HALF of the night (Time_Relative_sf > 5*3600)
temp2 <- data_t %>% 
  group_by(nm) %>% 
  subset(Time_Relative_sf > 5 * 3600) %>% 
  summarise(temp = mean(Tb.Tc, na.rm = TRUE))
data2 <- merge(data_i, temp2, by = "nm") # Merge with individual data

# Separate data2 into treatment groups
data2_m <- subset(data2, data2$treat == "maggot") # Blowfly group (M5-B2)
data2_c <- subset(data2, data2$treat == "control") # Control group (M5-C2)


# --------------------------------------------------------------------
# 3. Model Fitting (M5)
# Response: temp (Relative body temperature during the half-night)
# Predictors: mi_hier (Social Rank)
# --------------------------------------------------------------------

# M5-C1: First Half, Control (Figure S4A)
m1_c <- lm(temp ~ mi_hier, data = data1_c)
summary(m1_c)

# M5-B1: First Half, Blowfly (Figure S4C)
m1_m <- lm(temp ~ mi_hier, data = data1_m)
summary(m1_m)

# M5-C2: Second Half, Control (Figure S4B)
m2_c <- lm(temp ~ mi_hier, data = data2_c)
summary(m2_c)

# M5-B2: Second Half, Blowfly (Figure S4D)
m2_m <- lm(temp ~ mi_hier, data = data2_m)
summary(m2_m)


# --------------------------------------------------------------------
# 4. Statistical Analysis (Post-hoc Tests)
# --------------------------------------------------------------------

# Post-hoc comparison of ranks (mi_hier) for each model

em_m1_c <- emmeans(m1_c, ~ mi_hier) %>% pairs()
print("--- M5-C1 (First Half, Control) Post-hoc ---")
print(em_m1_c)

em_m1_m <- emmeans(m1_m, ~ mi_hier) %>% pairs()
print("--- M5-B1 (First Half, Blowfly) Post-hoc ---")
print(em_m1_m)

em_m2_c <- emmeans(m2_c, ~ mi_hier) %>% pairs()
print("--- M5-C2 (Second Half, Control) Post-hoc ---")
print(em_m2_c)

em_m2_m <- emmeans(m2_m, ~ mi_hier) %>% pairs()
print("--- M5-B2 (Second Half, Blowfly) Post-hoc ---")
print(em_m2_m)


# --------------------------------------------------------------------
# 5. Visualization (Figure S4A - S4D)
# --------------------------------------------------------------------

# --- Figure S4A: First Half, Control ---
figure_S4A <- ggplot(data = data1_c, aes(x = mi_hier, y = temp)) +
  geom_boxplot(fill = "grey") +
  theme_classic() +
  labs(x = "Social rank", y = "Relative body temperature (°C)") +
  coord_cartesian(ylim = c(-1, 5), expand = TRUE) +
  
  # Add significance bar (Rank 1 vs Rank 3: ***)
  geom_signif(
    y_position = c(4.5), xmin = c(1), xmax = c(3), 
    annotation = c("***"), tip_length = 0, size = 0.8, textsize = 8, vjust = 0.5
  ) +
  
  theme(text = element_text(size = 21)) +
  scale_x_discrete(labels = c("1" = "α", "2" = "β", "3" = "γ"))

print(figure_S4A)

# --- Figure S4B: Second Half, Control ---
figure_S4B <- ggplot(data = data2_c, aes(x = mi_hier, y = temp)) +
  geom_boxplot(fill = "grey") +
  theme_classic() +
  labs(x = "Social rank", y = "Relative body temperature (°C)") +
  coord_cartesian(ylim = c(-1, 5), expand = TRUE) +
  
  # Add significance bars (Rank 1 vs Rank 2: *, Rank 1 vs Rank 3: *)
  geom_signif(
    y_position = c(3.5, 4), xmin = c(1, 1), xmax = c(2, 3), 
    annotation = c("*", "*"), tip_length = 0, size = 0.8, textsize = 8, vjust = 0.5
  ) +
  
  theme(text = element_text(size = 21)) +
  scale_x_discrete(labels = c("1" = "α", "2" = "β", "3" = "γ"))

print(figure_S4B)

# --- Figure S4C: First Half, Blowfly ---
figure_S4C <- ggplot(data = data1_m, aes(x = mi_hier, y = temp)) +
  geom_boxplot(fill = "grey") + 
  theme_classic() +
  labs(x = "Social rank", y = "Relative body temperature (°C)") +
  coord_cartesian(ylim = c(-1, 5), expand = TRUE) +
  theme(text = element_text(size = 21)) +
  scale_x_discrete(labels = c("1" = "α", "2" = "β", "3" = "γ"))

print(figure_S4C)

# --- Figure S4D: Second Half, Blowfly ---
figure_S4D <- ggplot(data = data2_m, aes(x = mi_hier, y = temp)) +
  geom_boxplot(fill = "grey") + 
  theme_classic() +
  labs(x = "Social rank", y = "Relative body temperature (°C)") +
  coord_cartesian(ylim = c(-1, 5), expand = TRUE) +
  
  # Add significance bar (Rank 1 vs Rank 3: **)
  geom_signif(
    y_position = c(3.5), xmin = c(1), xmax = c(3), 
    annotation = c("**"), tip_length = 0, size = 0.8, textsize = 8, vjust = 0.5
  ) +
  
  theme(text = element_text(size = 21)) +
  scale_x_discrete(labels = c("1" = "α", "2" = "β", "3" = "γ"))

print(figure_S4D)

