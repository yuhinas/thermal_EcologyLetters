# --------------------------------------------------------------------
# 1. Load Required Libraries
# --------------------------------------------------------------------
library(ggplot2)    # For data visualization
library(ggsignif)   # For adding significance bars to ggplot
# --------------------------------------------------------------------
# 2. Data Loading and Preparation
# --------------------------------------------------------------------

# Read behavior data and individual data
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

# Select only nm and treat from individual data for merging
data_i <- data_i[, c("nm", "treat")]

# Merge individual data with calculated behavior variables
data1 <- merge(data_i, data_b[, c("nm", "conflict", "investment", "conflict_invest")])


# --------------------------------------------------------------------
# 3. Model Fitting (M9 & M10)
# --------------------------------------------------------------------

# M9: Cooperation (investment) ~ Treatment
cooperation <- lm(investment ~ treat, data = data1)
summary(cooperation)
anova(cooperation) # Get F value and p value

# M10: Conflict Index (conflict_invest) ~ Treatment
conflict <- lm(conflict_invest ~ treat, data = data1)
summary(conflict)
anova(conflict) # Get F value and p value

# --------------------------------------------------------------------
# 4. Visualization (Figure 4E & 4F)
# --------------------------------------------------------------------

# --- Figure 4E: Cooperation (M9) ---

# Create a data frame for prediction
xv_4E <- data.frame(treat = c("control", "maggot"))

# Get predicted values (fit) and standard errors (se.fit) from M9
yv_4E <- data.frame(predict(cooperation, xv_4E, type = "response", se.fit = TRUE), xv_4E)

# Calculate upper and lower bounds for the standard error (SE) error bars
yv_4E$upper <- yv_4E$fit + yv_4E$se.fit
yv_4E$lower <- yv_4E$fit - yv_4E$se.fit

figure_4E <- ggplot(data = yv_4E, aes(x = treat, y = fit, fill = treat)) +
  geom_col() +
  # Manual color scaling and labels (enforcing lower case labels)
  scale_fill_manual(
    name = "Treatment", 
    values = c("control" = "grey", "maggot" = "dimgray"),
    labels = c("control" = "control", "maggot" = "blowfly")
  ) +
  ylim(0,2300)+
  theme_classic() +
  theme(text = element_text(size = 21)) +
  # Error bars (based on SE) - Corrected the extra comma
  geom_errorbar(aes(ymin = lower, ymax = upper), 
                width = .1, 
                position = position_dodge(.9)) +
  labs(x = "", y = "Total cooperative investment (s)") +
  # Custom x-axis labels (enforcing lower case labels)
  scale_x_discrete(labels = c("control" = "control", "maggot" = "blowfly")) +
  # Add significance bar (Hard-coded for final figure aesthetics)
  geom_signif(
    y_position = c(2000), 
    xmin = c(1), 
    xmax = c(2), 
    annotation = c("***"), 
    tip_length = 0, 
    size = 0.8, 
    textsize = 7, 
    vjust = 0.3
  )

print(figure_4E)

# --- Figure 4F: Conflict Index (M10) ---

# Create a data frame for prediction
xv_4F <- data.frame(treat = c("control", "maggot"))

# Get predicted values (fit) and standard errors (se.fit) from M10
yv_4F <- data.frame(predict(conflict, xv_4F, type = "response", se.fit = TRUE), xv_4F)

# Calculate upper and lower bounds for the standard error (SE) error bars
yv_4F$upper <- yv_4F$fit + yv_4F$se.fit
yv_4F$lower <- yv_4F$fit - yv_4F$se.fit

figure_4F <- ggplot(data = yv_4F, aes(x = treat, y = fit, fill = treat)) +
  geom_col() +
  # Manual color scaling and labels (enforcing lower case labels)
  scale_fill_manual(
    name = "Treatment", 
    values = c("control" = "grey", "maggot" = "dimgray"),
    labels = c("control" = "control", "maggot" = "blowfly")
  ) +
  ylim(0,0.1)+
  theme_classic() +
  theme(text = element_text(size = 21)) + 
  # Error bars (based on SE) - Corrected the extra comma
  geom_errorbar(aes(ymin = lower, ymax = upper), 
                width = .1, 
                position = position_dodge(.9)) +
  # Axis labels: Adjusted Y-label to reflect Conflict Index (ratio)
  labs(x = "", y = "Number of social conflict (per unit time)") + 
  # Custom x-axis labels (enforcing lower case labels)
  scale_x_discrete(labels = c("control" = "control", "maggot" = "blowfly")) +
  # Add significance bar (Hard-coded for final figure aesthetics)
  geom_signif(
    y_position = c(0.08), 
    xmin = c(1), 
    xmax = c(2), 
    annotation = c("**"), 
    tip_length = 0, 
    size = 0.8, 
    textsize = 7, 
    vjust = 0.3
  )


print(figure_4F)


