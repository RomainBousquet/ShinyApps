library(ggplot2)
library(dplyr)

# Set color palette
cbPalette <- c("#999999","#E69F00", "#4288D5", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

df <- read.csv("data.csv")
m_dist <- mahalanobis(df, colMeans(df), cov(df))
df$m_dist <- m_dist
df$Outlier <- "No"
df$Outlier <- as.factor(df$Outlier)

ggplot(df, aes(x = weight, y = height, color = Outlier)) +
      geom_point(size = 4, alpha = 0.7) +
      labs(
            title = "Height vs Weight Plot",
            subtitle = "Detecting Outliers with Mahalanobis Distance",
            caption = "Source: http://wiki.stat.ucla.edu/socr/index.php/SOCR_Data_Dinov_020108_HeightsWeights"
      ) +
      xlab("Weight in kg") + ylab("Height in cm") +
      scale_x_continuous(breaks = seq(35, 80, 5)) +
      scale_y_continuous(breaks = seq(150, 200, 5)) +
      scale_colour_manual(values=cbPalette)

# Set Outlier Feature
thresh <- 5

df$Outlier <- "No"
df$Outlier[df$m_dist > thresh] <- "Yes"
df$Outlier <- as.factor(df$Outlier)

ggplot(df, aes(x = weight, y = height, color = Outlier)) +
      geom_point(size = 4, alpha = 0.7) +
      labs(
            title = "Height vs Weight Plot",
            subtitle = "Detecting Outliers with Mahalanobis Distance",
            caption = "Source: http://wiki.stat.ucla.edu/socr/index.php/SOCR_Data_Dinov_020108_HeightsWeights"
      ) +
      xlab("Weight in kg") + ylab("Height in cm") +
      scale_x_continuous(breaks = seq(35, 80, 5)) +
      scale_y_continuous(breaks = seq(150, 200, 5)) +
      scale_colour_manual(values=cbPalette)

dt <- df %>%
      filter(Outlier == "Yes") %>%
      select(height, weight, Outlier)

dt <- df %>%
      filter(Outlier == "Yes") %>%
      count(height)



class(dt)
