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
  titlePanel("Outlier Detection with Mahalanobis Distance"),
  
  # Sidebar with a slider input for Outlier Threshold 
  sidebarLayout(
    sidebarPanel(
          strong("Parameter Settings"),
          p("Use the slider to set your outlier threshold detection limit. The higher the threshold
            value, the less outlier are detected."),
          tags$hr(),
          sliderInput("threshold",
                       "Set Threshold:",
                       min = 5,
                       max = 25,
                       value = 20),
          tags$hr(),
          p("Number of outliers detected:"),
          strong(textOutput("num_outliers")),
          tags$hr(),
          p("Please click on the Documentation Tab for more details on how to use this application.")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
          tabsetPanel(type = "tabs",
                      tabPanel("Plot",
                               h4("Scatterplot of the Data"),
                               p("Height and weight data is shown in a scatterplot; it appears 
                                 normally distributed and has possible outliers. By using 
                                 Mahalanobis Distance calculation, the outliers that come from 
                                 unusual combinations between height and weight can be detected."),
                               plotOutput("plot"),
                               p("This works well for finding observations with high height values but
                                 low weight values, i.e. underweight people, or vice versa. The lower 
                                 the threshold is set, the more sensitive is the detection ratio.")),
                      tabPanel("Outliers", 
                               h4("Table of detected Outliers"),
                               p("Below table shows the observations that are classified as outliers 
                                 based on the current threshold setting. Change the threshold to 
                                 see more or less outliers. The table is sorted from highest to lowest 
                                 calculated Mahalanobis distance."), 
                               tableOutput("table")),
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
