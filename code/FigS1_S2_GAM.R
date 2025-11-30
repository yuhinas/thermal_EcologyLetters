# --------------------------------------------------------------------
# 1. Load Required Libraries
# --------------------------------------------------------------------
library(ggplot2)    # For data visualization
library(magrittr)   # For piping functionality (e.g., %>%)
# --------------------------------------------------------------------
# 2. Data Loading and Preparation
# --------------------------------------------------------------------
data_t <- read.csv("data/body_temp.csv")
data_i <- read.csv("data/individual.csv")

# Select necessary columns from individual data (nm, gender, mi_hier)
data_i <- data_i[, c("nm", "gender")]

# Merge time-series data with individual data
data_t <- merge(data_t, data_i, all.x = TRUE, by = "nm") 

# Create a combined factor for grouping (e.g., "female 1", "male 3")
data_t$group <- paste(data_t$gender, data_t$mi_hier)

# Separate data by treatment group
data_m <- subset(data_t, data_t$treat == "maggot") # Blowfly group
data_c <- subset(data_t, data_t$treat == "control") # Control group

# --------------------------------------------------------------------
# 3. Visualization (Figure S1 & S2)
# --------------------------------------------------------------------

# Define shared plot elements for simplicity
shared_theme <- list(
  theme_classic(),
  theme(text = element_text(size = 15)),
  labs(x = "Time", y = "Relative body temperature (°C)"),
  scale_x_continuous(
    breaks = c(0.0, 2.5, 5.0, 7.5, 10.0), 
    labels = c("19:00", "21:30", "00:00", "02:30", "05:00") 
  ),
  coord_cartesian(ylim = c(-0.5, 3), expand = TRUE)
)

## --- Figure S1: Control Group (6 Panels) ---

# female alpha (rank 1)
plot_S1_F1 <- data_c %>% subset(., group == "female 1") %>%
  ggplot(aes(x = Time_Relative_sf / 3600, y = Tb.Tc)) +
  geom_point(shape = 1, colour = "dimgrey") +
  geom_smooth(method = "gam", color = "black", formula = y ~ s(x, bs = "cs")) +
  shared_theme
print(plot_S1_F1)

# female beta (rank 2)
plot_S1_F2 <- data_c %>% subset(., group == "female 2") %>%
  ggplot(aes(x = Time_Relative_sf / 3600, y = Tb.Tc)) +
  geom_point(shape = 1, colour = "dimgrey") +
  geom_smooth(method = "gam", color = "black", formula = y ~ s(x, bs = "cs")) +
  shared_theme
print(plot_S1_F2)

# female gamma (rank 3)
plot_S1_F3 <- data_c %>% subset(., group == "female 3") %>%
  ggplot(aes(x = Time_Relative_sf / 3600, y = Tb.Tc)) +
  geom_point(shape = 1, colour = "dimgrey") +
  geom_smooth(method = "gam", color = "black", formula = y ~ s(x, bs = "cs")) +
  shared_theme
print(plot_S1_F3)

# male alpha (rank 1)
plot_S1_M1 <- data_c %>% subset(., group == "male 1") %>%
  ggplot(aes(x = Time_Relative_sf / 3600, y = Tb.Tc)) +
  geom_point(shape = 1, colour = "dimgrey") +
  geom_smooth(method = "gam", color = "black", formula = y ~ s(x, bs = "cs")) +
  shared_theme
print(plot_S1_M1)

# male beta (rank 2)
plot_S1_M2 <- data_c %>% subset(., group == "male 2") %>%
  ggplot(aes(x = Time_Relative_sf / 3600, y = Tb.Tc)) +
  geom_point(shape = 1, colour = "dimgrey") +
  geom_smooth(method = "gam", color = "black", formula = y ~ s(x, bs = "cs")) +
  shared_theme
print(plot_S1_M2)

# male gamma (rank 3)
plot_S1_M3 <- data_c %>% subset(., group == "male 3") %>%
  ggplot(aes(x = Time_Relative_sf / 3600, y = Tb.Tc)) +
  geom_point(shape = 1, colour = "dimgrey") +
  geom_smooth(method = "gam", color = "black", formula = y ~ s(x, bs = "cs")) +
  shared_theme
print(plot_S1_M3)


## --- Figure S2: Blowfly Group (6 Panels) ---

# female alpha (rank 1)
plot_S2_F1 <- data_m %>% subset(., group == "female 1") %>%
  ggplot(aes(x = Time_Relative_sf / 3600, y = Tb.Tc)) +
  geom_point(shape = 1, colour = "dimgrey") +
  geom_smooth(method = "gam", color = "black", formula = y ~ s(x, bs = "cs")) +
  shared_theme
print(plot_S2_F1)

# female beta (rank 2)
plot_S2_F2 <- data_m %>% subset(., group == "female 2") %>%
  ggplot(aes(x = Time_Relative_sf / 3600, y = Tb.Tc)) +
  geom_point(shape = 1, colour = "dimgrey") +
  geom_smooth(method = "gam", color = "black", formula = y ~ s(x, bs = "cs")) +
  shared_theme
print(plot_S2_F2)

# female gamma (rank 3)
plot_S2_F3 <- data_m %>% subset(., group == "female 3") %>%
  ggplot(aes(x = Time_Relative_sf / 3600, y = Tb.Tc)) +
  geom_point(shape = 1, colour = "dimgrey") +
  geom_smooth(method = "gam", color = "black", formula = y ~ s(x, bs = "cs")) +
  shared_theme
print(plot_S2_F3)

# male alpha (rank 1)
plot_S2_M1 <- data_m %>% subset(., group == "male 1") %>%
  ggplot(aes(x = Time_Relative_sf / 3600, y = Tb.Tc)) +
  geom_point(shape = 1, colour = "dimgrey") +
  geom_smooth(method = "gam", color = "black", formula = y ~ s(x, bs = "cs")) +
  shared_theme
print(plot_S2_M1)

# male beta (rank 2)
plot_S2_M2 <- data_m %>% subset(., group == "male 2") %>%
  ggplot(aes(x = Time_Relative_sf / 3600, y = Tb.Tc)) +
  geom_point(shape = 1, colour = "dimgrey") +
  geom_smooth(method = "gam", color = "black", formula = y ~ s(x, bs = "cs")) +
  shared_theme
print(plot_S2_M2)

# male gamma (rank 3)
plot_S2_M3 <- data_m %>% subset(., group == "male 3") %>%
  ggplot(aes(x = Time_Relative_sf / 3600, y = Tb.Tc)) +
  geom_point(shape = 1, colour = "dimgrey") +
  geom_smooth(method = "gam", color = "black", formula = y ~ s(x, bs = "cs")) +
  shared_theme
print(plot_S2_M3)

