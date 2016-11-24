#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(dplyr)
library(ggplot2)
library(shiny)

# Read data from CSV file
mydat <- read.csv("re_data.csv", stringsAsFactors = FALSE)
mydat$beds_cat <- as.factor(mydat$num_bedrooms)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Real Estate Demo App"),
   
   # Sidebar with input options
   sidebarLayout(
      sidebarPanel(
            sliderInput("priceInput",
                        "Price Range",
                        min = 135000, 
                        max = 450000,
                        value = c(135000, 450000), 
                        pre = "AED ",
                        step = 5000),
            sliderInput("areaInput",
                        "Area Range",
                        min = 2000,
                        max = 15000,
                        value = c(2000, 15000),
                        step = 100),
            sliderInput("bedsInput",
                        "Bedroom Range",
                        min = 0,
                        max = 5,
                        value = c(0, 5)),
            checkboxInput("bedsColorInput",
                          "Show Bedrooms",
                          value = TRUE),
            selectInput("model",
                        "Model Type",
                        choices = c("None" = "none",
                                    "Linear" = "lm",
                                    "Smooth" = "smooth"))
      ),
      
      # Show a plot of the data
      mainPanel(
            plotOutput("scatterPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$scatterPlot <- renderPlot({
         
         minPrice <- input$priceInput[1]
         maxPrice <- input$priceInput[2]
         
         filtered <- mydat %>%
               filter(yearly_price >= input$priceInput[1],
                      yearly_price <= input$priceInput[2],
                      area_sqft >= input$areaInput[1],
                      area_sqft <= input$areaInput[2],
                      num_bedrooms >= input$bedsInput[1],
                      num_bedrooms <= input$bedsInput[2]
                      )
         
         # XY Scatter Plot, X = Area, Y = Price
         ## Add bedroom color and size option
         if (input$bedsColorInput == TRUE) {
               g <- ggplot(filtered, aes(x = area_sqft, y = yearly_price, color = num_bedrooms)) +
                     geom_point(size = 5, alpha = 0.5) +
                     theme(legend.position="bottom")
         }
         else {
               g <- ggplot(filtered, aes(x = area_sqft, y = yearly_price)) +
                     geom_point(size = 5, alpha = 0.5)
         }
         
         g <- g + labs(
                     title = "Real Estate Data",
                     subtitle = paste0("Prices from ", formatC(minPrice, big.mark = ","), 
                                       " to ", formatC(maxPrice, big.mark = ","), " AED"),
                     caption = "Source: various real estate websites"
               ) +
               xlab("Area in sqft") + ylab("Yearly Rent in AED") +
               scale_y_continuous(labels = scales::comma) +
               scale_x_continuous(labels = scales::comma)
         
         if (input$model == "lm") {
               g <- g + geom_smooth(method = "lm")
         }
         else if (input$model == "smooth") {
               g <- g + geom_smooth(method = "loess")
         }
         
         g
   })
}

# Run the application 
shinyApp(ui = ui, server = server)
