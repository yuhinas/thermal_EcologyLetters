# --------------------------------------------------------------------
# 1. Load Required Libraries
# --------------------------------------------------------------------
library(magrittr)   # For piping functionality (e.g., %>%) 
library(dplyr)      # For data manipulation and piping 
library(stringr)    # For string manipulation (used in significance plotting) 
library(car)        # For Type 3 ANOVA
library(emmeans)    # For estimated marginal means and post-hoc tests
library(ggplot2)    # For data visualization
# --------------------------------------------------------------------
# 2. Data Loading and Preparation
# --------------------------------------------------------------------

# Read the full dataset (individual-level data)
data_i <- read.csv("data/individual.csv")

# Convert the social rank variable (mi_hier) to a factor
data_i$mi_hier <- as.factor(data_i$mi_hier)

# Standardize the body size variable (i_width) to a Z-score
data_i$size_z <- scale(data_i$i_width, center = TRUE, scale = TRUE)

# --------------------------------------------------------------------
# 3. Model Fitting (M2)
# Response: mean_temp
# Predictors: treat * mi_hier + size_z + size_z:mi_hier
# --------------------------------------------------------------------
m_size <- lm(mean_temp ~ treat * mi_hier + size_z + size_z:mi_hier, data = data_i)

# Display model summary (Coefficients)
summary(m_size)

# Perform Type 3 ANOVA for main effects and interactions）
anova_results <- Anova(m_size, type = 3)
print(anova_results)

# --------------------------------------------------------------------
# 4. Statistical Analysis (Post-hoc Tests)
# Note: Results are based on the continuous covariate 'size_z' at its mean (0) by default.
# --------------------------------------------------------------------

# Comparison of treatments (treat) within each rank (mi_hier)
em_treat_within_rank <- emmeans(m_size, ~ treat | mi_hier + size_z, type = "response") %>% pairs()

# Comparison of ranks (mi_hier) within each treatment (treat)
em_rank_within_treat <- emmeans(m_size, ~ mi_hier | treat + size_z, type = "response") %>% pairs()

# Print post-hoc results
print("--- Post-hoc: Treat within Rank ---")
print(em_treat_within_rank)
print("--- Post-hoc: Rank within Treat ---")
print(em_rank_within_treat)

# --------------------------------------------------------------------
# 5. Visualization (Figure S8)
# --------------------------------------------------------------------

# Define quartiles of body size Z-score for plotting
qs <- quantile(data_i$size_z, probs = c(.25, .5, .75), na.rm = TRUE)

# Calculate Estimated Marginal Means (EMMs) at specified quartiles for plotting
emm_sz <- emmeans(
  m_size,                                
  ~ mi_hier | treat * size_z,            
  at = list(size_z = as.numeric(qs)),    
  type = "response"
)

# Convert EMMs to a data frame
emm_df <- as.data.frame(emm_sz)

# Calculate error bar boundaries using Standard Error (SE)
emm_df$lower <- emm_df$emmean - emm_df$SE
emm_df$upper <- emm_df$emmean + emm_df$SE

# Add descriptive labels for the size quartiles
emm_df <- emm_df %>%
  mutate(
    size_lab = factor(
      size_z,
      levels = as.numeric(qs),
      labels = c("Body size Q25", "Body size Q50", "Body size Q75")
    )
  )

# --- Significance Bar Calculation (Dynamic) ---

# Calculate pairwise comparisons for ranks at each size quartile
comparisons_rank <- pairs(emm_sz)

# Calculate pairwise comparisons for treatments at each size quartile
comparisons_treat <- emmeans(
  m_size,                                
  ~ treat | mi_hier * size_z,            
  at = list(size_z = as.numeric(qs)),    
  type = "response"
) %>% pairs()

# Process rank comparisons to determine significance stars and X/Y positions
significant_rank <- as.data.frame(comparisons_rank) %>%
  filter(p.value < 0.05) %>%
  mutate(
    # Assign significance stars based on p-value
    label = case_when(
      p.value < 0.001 ~ "***",
      p.value < 0.01  ~ "**",
      p.value < 0.05  ~ "*"
    )
  )

# Mapping x-axis factor levels to numeric positions
map_x <- c(mi_hier1 = 1, mi_hier2 = 2, mi_hier3 = 3)

# Calculate X positions for rank comparisons
significant_rank <- significant_rank %>%
  mutate(
    # Extract mi_hier levels from contrast string
    left  = str_trim(str_split_fixed(contrast, "-", 2)[, 1]),
    right = str_trim(str_split_fixed(contrast, "-", 2)[, 2])
  ) %>%
  mutate(
    # Offset adjustment for 'dodge' position (Control vs. Treatment)
    offset  = if_else(treat == "maggot", -0.2, 0.2), # Assuming 'maggot' is one treatment group
    x_start = unname(map_x[left])  + offset,
    x_end   = unname(map_x[right]) + offset
  )

# Calculate Y positions for rank comparisons
max_y <- emm_df %>% group_by(size_z) %>%
  summarise(y_base = max(upper) + 0.2, .groups = "drop")
significant_rank <- significant_rank %>%
  left_join(max_y, by = "size_z") %>%
  group_by(size_z) %>%
  mutate(
    line_id = row_number(),
    y_pos   = y_base + 0.2 * line_id # Stacking significance lines
  )

# Process treatment comparisons to determine significance stars and Y positions
significant_treat <- as.data.frame(comparisons_treat) %>%
  filter(p.value < 0.05) %>%
  mutate(
    # Assign significance stars
    label = case_when(
      p.value < 0.001 ~ "***",
      p.value < 0.01  ~ "**",
      p.value < 0.05  ~ "*"
    )
  )

# Calculate X positions for treatment comparisons (between the two bars)
significant_treat$x_start <- as.numeric(significant_treat$mi_hier) - 0.2
significant_treat$x_end   <- as.numeric(significant_treat$mi_hier) + 0.2

# Calculate Y positions for treatment comparisons
max_y_treat <- emm_df %>%
  group_by(size_z, mi_hier) %>%
  summarise(y_pos = max(upper) + 0.2, .groups = "drop")
significant_treat <- merge(significant_treat, max_y_treat, all.x = TRUE)

# --- Final Merge and Setup ---

# Select necessary columns and combine all significant results
significant_rank <- significant_rank %>% select(size_z, x_start, x_end, y_pos, label)
significant_treat <- significant_treat %>% select(size_z, x_start, x_end, y_pos, label)
significant <- rbind(significant_rank, significant_treat)

# Apply size labels to the final significance data frame
significant <- significant %>%
  mutate(
    size_lab = factor(
      size_z,
      levels = as.numeric(qs),
      labels = c("Body size Q25", "Body size Q50", "Body size Q75")
    )
  )

# --------------------------------------------------------------------
# 6. Plotting (Figure S8)
# --------------------------------------------------------------------

figure_S8 <- ggplot(data = emm_df, aes(x = mi_hier, y = emmean, fill = treat)) +
  # Bar plots for EMMs
  geom_col(position = "dodge") +
  
  # Error bars
  geom_errorbar(aes(ymin = lower, ymax = upper), width = .1, position = position_dodge(.9)) +
  
  # Theme and labels
  theme_classic() +
  theme(text = element_text(size = 21)) +
  labs(x = "Social Rank", y = "Relative body temperature (°C)") +
  
  # Manual color scaling
  scale_fill_manual(
    name = "Treatment",
    labels = c("maggot" = "blowfly"), # Adjust labels as needed
    values = c("control" = "grey", "maggot" = "dimgray")
  ) +
  
  # Facet by body size quartile
  facet_wrap(~ size_lab) +
  
  # Add significance lines (segments)
  geom_segment(data = significant,
               aes(x = x_start, xend = x_end, y = y_pos, yend = y_pos),
               inherit.aes = FALSE, linewidth = 0.5) +
  
  # Add significance text (stars)
  geom_text(data = significant,
            aes(x = (x_start + x_end) / 2, y = y_pos, label = label),
            inherit.aes = FALSE,
            vjust = 0.2, size = 7) +
  
  # Custom x-axis labels (Rank 1, 2, 3 to Greek letters)
  scale_x_discrete(labels = c("1" = "α", "2" = "β", "3" = "γ"))

# Display the figure

print(figure_S8)
