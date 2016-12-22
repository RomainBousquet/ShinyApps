#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

# Load libraries
library(shiny)
library(ggplot2)
library(dplyr)

# Set color palette
cbPalette <- c("#999999","#E69F00", "#4288D5", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Initial Data - Read and add features
df <- read.csv("data.csv")
m_dist <- mahalanobis(df, colMeans(df), cov(df))
df$m_dist <- m_dist

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

      # Plot Output
      output$plot <- renderPlot({

            # Calculate Outlier Feature
            df$Outlier <- "No"
            df$Outlier[df$m_dist > input$threshold] <- "Yes"
            df$Outlier <- as.factor(df$Outlier)
            
            # Create the Plot
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
      
      })
      
      # Table Output - Create table of outliers
      output$table <- renderTable({

            df$Outlier <- "No"
            df$Outlier[df$m_dist > input$threshold] <- "Yes"
            df$Outlier <- as.factor(df$Outlier)
            
            dt <- df %>%
                  filter(Outlier == "Yes") %>%
                  select(height, weight, m_dist) %>%
                  arrange(desc(m_dist)) %>%
                  rename(Height = height, Weight = weight, Mahalanobis_Distance = m_dist)

      })
      
      # Number of Outliers Text Output
      output$num_outliers <- renderText({

            df$Outlier <- 0
            df$Outlier[df$m_dist > input$threshold] <- 1

            sum(df$Outlier)

      })

      # Documentation Output
      output$doc <- renderText({



      })
  
})
