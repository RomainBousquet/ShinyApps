#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(plyr)
library(ggplot2)

# Define server logic
shinyServer(function(input, output) {
   
   v <- reactiveValues(doMCS = FALSE)
   
   observeEvent(input$go, {
      # 0 will be coerced to FALSE
      # 1+ will be coerced to TRUE
      v$doMCS <- input$run_MCS
   })
   
   # Code to create Input Model (Beta Distribution)
   output$beta_plot <- renderPlot({
      
      # Create Beta Distribution
      x <- seq(0, 1, length=1000)
      beta <- dbeta(x, input$alpha, input$beta)
      # Create x-Axis scale
      prod <- seq(input$min_max_prod[1], input$min_max_prod[2], length = 1000)   # x-Axis
      # merge into data frame
      df_beta <- data.frame(prod = prod, beta = beta)
      
      # Draw Plot
      ggplot(df_beta, aes(x = prod, y = beta)) +
         geom_line(size = 1.5, color = "deepskyblue1", alpha = 0.7) +
         labs(
            title = "Production Distribution Plot",
            subtitle = "Approximate single well production distribution"
         ) +
         xlab("Single Well Production in BOPD") +
         ylab("Beta / Density") +
         scale_x_continuous(breaks = seq(input$min_max_prod[1], input$min_max_prod[2], 50))
      
   })
   
   # Well Example Plot based on number of wells and beta distribution
   output$well_plot <- renderPlot({
      
      # Init
      iterations <- 100
      distr <- seq(0, 0, length = input$num_wells)
      
      # Loop to create iterations
      for (i in c(1:iterations)) {
         
         distr <- distr + sort(rbeta(input$num_wells, 
                                     input$alpha, 
                                     input$beta))
         
      }
      
      # Average  the sorted distribution
      distr <- distr / iterations
      
      # Assign well production values
      well_prod <- 2 * input$min_max_prod[1] + (distr * input$min_max_prod[2] - input$min_max_prod[1])
      
      df <- data.frame(well_prod)
      df$upper_prod <- round_any(df$well_prod, 100, f = ceiling)
      
      # Aggregate - new data frame
      c <- dplyr::count(df, upper_prod)

      ggplot(c, aes(x = upper_prod, y = n)) +
         geom_bar(stat = 'identity', fill = "deepskyblue1", alpha = 0.7) +
         scale_x_continuous(breaks = c$upper_prod,
                            labels = paste0(c$upper_prod-100, " - ", c$upper_prod)) +
         scale_y_continuous(breaks = seq(0, max(c$n), 2)) +
         coord_flip() +
         labs(
            title = paste0("Example Distribution with ", input$num_wells, " wells"),
            subtitle = "Based on the distribution input parameters"
         ) +
         xlab("Production Range - BOPD") +
         ylab("Number of wells that fall within each range bucket") +
         geom_text(aes(x = upper_prod, y = n, label = n), hjust = 1, nudge_y = -0.4, fontface = "bold")
      
   })
   
   # Calculate MCS
   mcs_df <- eventReactive(input$run_MCS, {
      
      # Number of simulations (fixed)
      runs <- 5000
      
      # Init
      total_prod <- c()
      
      # Simulation Loop
      for (i in c(1:runs)) {
         
         # Create a randomized beta distribution
         beta <- rbeta(input$num_wells, 
                       shape1 = input$alpha, 
                       shape2 = input$beta)
         
         # Convert into production well data
         well_prod <- input$min_max_prod[1] + 
            (beta * input$min_max_prod[2] - input$min_max_prod[1])
         
         if (is.null(total_prod)) {
            total_prod <- sum(well_prod)
         } else {
            total_prod <- append(total_prod, sum(well_prod))
         }
      }
      
      # Convert to single feature data frame
      data.frame(field_prod = total_prod)
      
   })
   
   # Code to plot the MC distribution
   output$prod_distr_plot <- renderPlot({
      
      # Set data frame, calculate additional data
      df <- mcs_df()
      avg <- round(mean(df$field_prod, na.rm = TRUE), 0)
      q05 <- round(quantile(df$field_prod, 0.05))
      q95 <- round(quantile(df$field_prod, 0.95))
      
      # Plot
      ggplot(df, aes(x = field_prod, y=100*(..count..)/sum(..count..))) + 
         geom_histogram(bins = 50) +
         labs(
            title = paste0("Average Field Production: ",
                           format(avg, big.mark = ","), " BOPD"),
            subtitle = paste0(input$num_wells, " wells - 5,000 simulations")
         ) +
         xlab("Field Production in BOPD") +
         ylab("Occurance Percentage") +
         geom_vline(xintercept = avg, size = 1, color = 'deepskyblue1', alpha = 0.8) +
         geom_vline(xintercept = c(q05, q95), size = 1, color = 'deepskyblue1', 
                    alpha = 0.5, linetype = "dashed")
   })
   
   output$cdf_plot <- renderPlot({
      
      # Set data frame, calculate additional data
      df <- mcs_df()
      avg <- round(mean(df$field_prod, na.rm = TRUE), 0)
      q05 <- round(quantile(df$field_prod, 0.05), 0)
      q95 <- round(quantile(df$field_prod, 0.95), 0)
      
      ggplot(df, aes(x = field_prod)) + 
         stat_ecdf(geom = "step", pad = FALSE, size = 1) +
         geom_hline(yintercept = c(0,1), size = 1, linetype = "dotted") +
         labs(
            title = "Uncertainty in Daily Production",
            subtitle = paste0("90% Probability that the field production is between ",
                              format(q05, big.mark = ","), " BOPD and ", 
                              format(q95, big.mark = ","), " BOPD")
         ) +
         scale_y_continuous(labels = scales::percent, 
                            breaks = seq(0, 1, 0.1)) +
         xlab("Total Daily Production in BOPD") +
         ylab("Probability of Daily Production being lower than indicated") +
         geom_vline(xintercept = avg, size = 1, color = 'deepskyblue1', alpha = 0.8) +
         geom_vline(xintercept = c(q05, q95), size = 1, color = 'deepskyblue1', 
                    alpha = 0.5, linetype = "dashed") +
         annotate("rect", xmin = q05, xmax = q95, ymin = 0, ymax = 1, 
                  fill = 'deepskyblue1', alpha = 0.1)
      
   })
   
   # Data Table - 5% increments
   output$table <- renderTable({
      
      # Initial Data Frame
      df <- mcs_df()
      
      # Create Features
      P <- seq(0, 1, length = 21)      # Probabilities from 0 to 1 in 5% steps
      Prob <- round(seq(1, 0, length = 21) * 100, 0)     # Probabilities from 1 to 0 in 5% steps
      Min_Expected_Prod <- round(quantile(df$field_prod, P), 0)    # Production Quantiles
      
      # Create Data Frame for Table Output
      tbl <- data.frame(Probability = Prob, Min_Expected_Prod)
      
      # Format Probability
      tbl$Probability <- paste0(tbl$Probability, " %")
      
      # Format Minimum Expected Production (comma separated values)
      tbl$Min_Expected_Prod <- format(tbl$Min_Expected_Prod, big.mark = ",")
      
      # Add Unit Column
      tbl$Unit <- "BOPD"
      
      # Return the dataframe
      tbl
      
   })
   
})

