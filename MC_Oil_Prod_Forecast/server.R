#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)

# Define server logic required to draw a histogram
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
                  geom_line(size = 1.5, color = "blue", alpha = 0.7) +
                  labs(
                        title = "Production Distribution Plot",
                        subtitle = "Approximate single well production distribution"
                  ) +
                  xlab("Single Well Production in BOPD") +
                  ylab("Beta / Density") +
                  scale_x_continuous(breaks = seq(input$min_max_prod[1], input$min_max_prod[2], 50))
            
      })
      
      
      
      
      
        output$distPlot <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    x    <- faithful[, 2] 
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
  })
  
})
