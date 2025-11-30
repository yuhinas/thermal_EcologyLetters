# --------------------------------------------------------------------
# 1. Load Required Libraries
# --------------------------------------------------------------------
library(magrittr)   # For piping functionality (e.g., %>%)
library(dplyr)      # For data manipulation and piping 
library(ggplot2)    # For data visualization
library(ggsignif)   # For adding significance bars to ggplot
# --------------------------------------------------------------------
# 2. Data Loading and Preparation
# --------------------------------------------------------------------

# Read individual-level data and time-series body temperature data
data_i <- read.csv("data/individual.csv") 
data_t <- read.csv("data/body_temp.csv")

# --- First Half of the Night (Time_Relative_sf <= 5*3600 seconds) ---

# Calculate mean relative body temperature (temp) for the first half of the night
temp1 <- data_t %>% 
  group_by(nm) %>% 
  subset(Time_Relative_sf <= 5 * 3600) %>% 
  summarise(temp_first_half = mean(Tb.Tc, na.rm = TRUE))

# Merge individual data with first half temperature data
data1 <- merge(data_i, temp1, by = "nm")

# --- Second Half of the Night (Time_Relative_sf > 5*3600 seconds) ---

# Calculate mean relative body temperature (temp) for the second half of the night
temp2 <- data_t %>% 
  group_by(nm) %>% 
  subset(Time_Relative_sf > 5 * 3600) %>% 
  summarise(temp_second_half = mean(Tb.Tc, na.rm = TRUE))

# Merge individual data with second half temperature data
data2 <- merge(data_i, temp2, by = "nm")


# --------------------------------------------------------------------
# 3. Model Fitting (M4-1: First Half, M4-2: Second Half)
# Response: temp_[half] (Relative body temperature)
# Predictors: treat (Treatment)
# --------------------------------------------------------------------

# M4-1: First Half
m1 <- lm(temp_first_half ~ treat, data = data1)
summary(m1)

# M4-2: Second Half
m2 <- lm(temp_second_half ~ treat, data = data2)
summary(m2)

# --------------------------------------------------------------------
# 4. Visualization (Figure S3A: First Half, Figure S3B: Second Half)
# --------------------------------------------------------------------

# Create a data frame for prediction
xv <- data.frame(treat = c("control", "maggot"))

# Get predicted values (fit) and standard errors (se.fit) from M4-1）
yv1 <- data.frame(predict(m1, xv, type = "response", se.fit = TRUE), xv)
# Calculate error bar boundaries
yv1$upper <- yv1$fit + yv1$se.fit
yv1$lower <- yv1$fit - yv1$se.fit

# Get predicted values (fit) and standard errors (se.fit) from M4-2
yv2 <- data.frame(predict(m2, xv, type = "response", se.fit = TRUE), xv)
# Calculate error bar boundaries
yv2$upper <- yv2$fit + yv2$se.fit
yv2$lower <- yv2$fit - yv2$se.fit

# --- Plot S3A (First Half) ---
figure_S3A <- ggplot(data = yv1, aes(x = treat, y = fit, fill = treat)) +
  geom_col(position = "dodge") +
  scale_fill_manual(
    name = "Treatment", 
    values = c("control" = "grey", "maggot" = "dimgray"),
    labels = c("maggot" = "blowfly")
  ) +
  scale_x_discrete(labels = c("maggot" = "blowfly")) +
  theme_classic() +
  theme(text = element_text(size = 21)) + 
  geom_errorbar(aes(ymin = lower, ymax = upper), 
                width = .1, 
                position = position_dodge(.9)) +
  labs(x = "", y = "Relative body temperature (°C)")+
  ylim(0,1.5)

# --- Plot S3B (Second Half) ---
figure_S3B <- ggplot(data = yv2, aes(x = treat, y = fit, fill = treat)) +
  geom_col(position = "dodge") +
  scale_fill_manual(
    name = "Treatment", 
    values = c("control" = "grey", "maggot" = "dimgray"),
    labels = c("maggot" = "blowfly")
  ) +
  scale_x_discrete(labels = c("maggot" = "blowfly")) +
  theme_classic() +
  theme(text = element_text(size = 21)) + 
  geom_errorbar(aes(ymin = lower, ymax = upper), 
                width = .1, 
                position = position_dodge(.9)) +
  labs(x = "", y = "Relative body temperature (°C)") +
  
  # Add significance bar (Hard-coded for final figure aesthetics)
  geom_signif(
    y_position = c(0.6), 
    xmin = c(1), 
    xmax = c(2), 
    annotation = c("**"),
    tip_length = 0, 
    size = 0.8, 
    textsize = 7, 
    vjust = 0.3
  )+
  
  ylim(0,1.5)

# Display the figures
print(figure_S3A)
print(figure_S3B)

