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
                     min = 0, max = 2000, value = c(0, 1000), step = 50),
         
         # Shape Parameters alpha (= shape1) and beta (= shape2)
         sliderInput("alpha", "Shape Parameter 1:",
                     min = 1, max = 20, value = 2),
         sliderInput("beta", "Shape Parameter 2:",
                     min = 1, max = 20, value = 4),
         
         # 'Run MCS' Action Button
         tags$hr(),
         actionButton("run_MCS", "Create Forecast")

      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         tabsetPanel(type = "tabs",
                     
                     # Well Model (input) Tab Panel
                     tabPanel("Field Model",
                              # Explanation / Text
                              h3("Field Model"),
                              p("The shown distribution represents a model of the oilfield - a distribution 
                                curve representing all wells of the field; it is a beta distribution using the 
                                shown input parameters."),
                              
                              # Display Input Plot
                              h4("Well Production Distribution Model"),
                              plotOutput("beta_plot"),
                              
                              # Display Well Plot
                              h4("Well Example Plot"),
                              p("This plot shows how many wells fall into which production range, based on 
                                the used input parameters. It is created through randomized sampling, so 
                                it will not always show the exact same well numbers."),
                              plotOutput("well_plot")
                              
                        ),
                     
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
                              p("The table shows the probabilities of minimum expected production of 
                                the simulated oilfield."),
                              tableOutput("table")),
                     
                     # Application Documentation / Usage Instructions
                     tabPanel("Documentation", 
                              # Introduction
                              h4("How to use the Application"),
                              p("This application can be used to get a better understanding about the 
                                single well production distribution. The Beta distribution is used as 
                                underlying model, and its input parameters can be changed. The 
                                created input distribution is then used together with other inputs 
                                to forecast the daily production output of the entire oilfield."),
                              tags$hr(),
                              
                              # Input Parameters
                              h4("Input Parameters"),
                              p("The input parameters are used to create the production forecast."),
                              tags$ul(
                                 tags$li("Number of wells: 10 - 100"),
                                 tags$li("Well Production Range: 0 - 2,000 BOPD for a single well"),
                                 tags$li("Shape Parameters: to change the shape of the beta distribution")
                              ),
                              p("To create a new or updated forecast, click on the CREATE FORECAST button."),
                              tags$hr(),
                              
                              # Field Model
                              h4("Field Model"),
                              p("The field model, here represented as a beta distribution, is one of the
                                inputs for the Monte Carlo simulation. It tries to approximate the number 
                                of wells that have a certain production range."),
                              p("A beta distribution with shape parameters 1 and 2 being 2 and 5, respectively, 
                                will create a field model where the majority of the wells produce a low 
                                amount of oil, while there are only very few high production wells."),
                              p("This model could represent an old oilfield, where most wells are old 
                                and produce only small amounts of oil, with a few newly drilled wells that
                                still have a high production rate."),
                              p("The other parameter used in the field model is the number of wells in 
                                the field."),
                              tags$hr(),
                              
                              # Production Forecast
                              h4("Production Forecast"),
                              p("The production forecast is calculated through Monte Carlo simulation, by 
                                sampling from the input distribution. As many samples as wells are taken, 
                                and the sampling process is done 5,000 times."),
                              p("The results of the Monte Carlo simulation are presented in three outputs."),
                              strong("Production Distribution Plot"),
                              p("This plot shows the simulation results as a histogram, with the average 
                                result and the 5% and 95% quantiles included as vertical blue lines. 90% of 
                                all forecasts fall between the two dashed lines."),
                              strong("Cumulative Distribution Plot"),
                              p("The easiest way of interpreting the simulation result is the CDF curve. The 
                                y-axis shows the probability of the production forecast being below a certain 
                                value."),
                              tags$em("Example:"),
                              p("Q: You would like to know the minimum expected field production, with an 
                                error probability of maximum 10%."),
                              p("A: Go to the y-axis to the 10% marker. Draw a horizontal line to the right 
                                until you reach the CDF curve. Then go down and read the production forecast 
                                value. There is a 10% chance that the production will be below this value, 
                                and a 90% changce that the production will be above this value."),
                              strong("Data Table"),
                              p("The data table displays the percentile results in 5% steps."),
                              tags$hr(),
                              
                              # Other Q & A's
                              h4("FAQ's"),
                              strong("Q:"),
                              p("Why do I get slightly different results each time I run the simulation 
                                again, although I did not change any inputs?"),
                              strong("A:"),
                              p("A Monte Carlo simulation is a randomized experiment; each simulation 
                           uses random numbers to run, and these numbers are always different. Over 
                           several thousand simulations they tend to balance each other out, but there 
                           is still some variance in the results."),
                              p("In fact, having a Monte Carlo simulation that does not show any variance 
                           should be reason for concern, as that means that it is more deterministic 
                           than it should be."),
                              strong("Q:"),
                              p("I cannot see any plots!"),
                              strong("A:"),
                              p("Click the CREATE FORECAST button and give it some time. The server will 
                           re-run the simulations and display them once ready."),
                              strong("Q:"),
                              p("I want to run simulations with more wells and higher production values, 
                           is it possible?"),
                              strong("A:"),
                              p("Not with this application. The parameter ranges are fixed because server 
                           resources are limited.")
                              ))
                              )
                              )
                              ))
