#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Oil Production Forecast with Monte Carlo Simulation"),
  p("Probabilistic Production Forecasting - Enabling Decision Making under Uncertainty"),
  
  # Sidebar with Simulator Inputs 
  sidebarLayout(
    sidebarPanel(
       h4("Input Parameters"),
       tags$hr(),

       # Number of Wells
       sliderInput("num_wells", "Number of Wells:",
                   min = 10, max = 100, value = 50),
       
       # Minimum and Maximum Well Production
       sliderInput("min_max_prod", "Well Production Range (BOPD):",
                   min = 0, max = 2000, value = c(50, 1000), step = 50),
       
       # Shape Parameters alpha (= shape1) and beta (= shape2)
       sliderInput("alpha", "Shape Parameter 1:",
                   min = 2, max = 10, value = 2),
       sliderInput("beta", "Shape Parameter 2:",
                   min = 2, max = 10, value = 4)
       
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
          tabsetPanel(type = "tabs",
                      
                # Well Model (input) Tab Panel
                tabPanel("Well Model",
                         # Explanation / Text
                         h3("Well Model"),
                         p("The shown distribution represents the approximate single well 
                           production distribution; it is a beta distribution using the 
                           shown input parameters."),
                         
                         # Display Input Plot
                         h4("Well Production Distribution Model"),
                         plotOutput("beta_plot"),
                         
                         # 'Run MCS' Action Button
                         actionButton("run_MCS", "Create Forecast")),
                
                # Output Tab Panel
                tabPanel("Production Forecast", 
                         # Explanation / Text
                         h3("Results of Monte Carlo Production Forecast"),
                         p("The simulation results are shown below. The first plot is the 
                           production forecast histogram; the second plot is the CDF curve. 
                           The table shows the forecasted daily production depending on 
                           probability of occurance."), 
                         
                         # Production Distribution Plot
                         h4("Production Distribution Plot"),
                         plotOutput("prod_distr_plot"),
                         
                         # CDF Curve
                         h4("Cumulative Distribution Plot"),
                         plotOutput("cdf_plot"),
                         
                         # Table of 10%-Probability Steps - Production
                         h4("Data Table"),
                         tableOutput("table")),
                
                # Application Documentation / Usage Instructions
                tabPanel("Documentation", 
                         h4("How to use the Application"),
                         p("This application can be used to demonstrate how outliers are 
                           detected by using Mahalanobis Distance calculation. Opposite to 
                           using maximum and/or minimum values of single features of the 
                           dataset, Mahalanobis distance uses combinations of features and 
                           highlights unusual combinations."),
                         tags$hr(),
                         h4("Calculation Details"),
                         p("Mahalanobis distance can be calculated as below: "),
                         code("m_dist <- mahalanobis(df, colMeans(df), cov(df))"),
                         p("as long as a data frame exists that contains all features to be 
                           used in the calculation."),
                         tags$hr(),
                         h4("Data Visualization"),
                         p("The data is visualized in a scatterplot in the PLOT tab. Click on 
                           it to see the plot. Dark yellow data points are showing the detected 
                           outliers."),
                         p("By changing the threshold on the slider on the left sidebar, the 
                           number of outliers detected can be changed. Higher threshold means 
                           less outliers, lower threshold means more outliers."),
                         tags$hr(),
                         h4("Data Table"),
                         p("The detected outliers are displayed as data table in the OUTLIERS tab.
                           Click on it to see them displayed. When changing the threshold with the
                           slider on the left sidebar, the table will adjust accordingly. Values 
                           are sorted from highest Mahalanobis distance to lowest."),
                         tags$hr(),
                         h4("Special Notes on Threshold Setting"),
                         p("Sometimes when the threshold is changed, there is no change in data 
                           output, i.e. no more or less outliers appear. This is not a program 
                           error; the reason is that there is sometimes no Mahalanobis distance 
                           that falls within the newly selected threshold."),
                         p("You can test this by changing the threshold when in data table view. 
                           When you change the slider value from 20 to 19, nothing will change. 
                           Only once you set it to 13 a new outlier will show in the table. The 
                           calculated Mahalanobis Distance value is 13.10, hence there were no 
                           data points with higher distance values.")
                         ))
            )
      )
))
