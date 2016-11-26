#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# PART 1 - Load Libraries and Data
library(dplyr)           # For data manipulation
library(ggplot2)         # For drawing plots
library(shiny)           # For running the app

# Read data from CSV file
mydat <- read.csv("re_data.csv", stringsAsFactors = FALSE)


# PART 2 - Define User Interface
ui <- fluidPage(
   
   # Application title
   titlePanel("Real Estate Demo App"),
   
   # Sidebar with input options
   sidebarLayout(
      sidebarPanel(
            
            # Filter Input for Rental Price Range
            sliderInput("priceInput",                  # Name of input
                        "Price Range",                 # Display Label
                        min = 135000,                  # Lowest Value of Range
                        max = 450000,                  # Highest Value of Range
                        value = c(135000, 450000),     # Pre-selected values
                        pre = "AED ",                  # Unit to display
                        step = 5000),                  # Size per step change
            
            # Filter Input for Area in sqft
            sliderInput("areaInput",                   # Name of input
                        "Area Range",                  # Display Label
                        min = 2000,                    # Lowest Value of Range
                        max = 15000,                   # Highest Value of Range
                        value = c(2000, 15000),        # Pre-selected values
                        step = 100),                   # Size per step change
            
            # Filter Input for Number of Bedrooms
            sliderInput("bedsInput",                   # Name of input
                        "Bedroom Range",               # Display Label
                        min = 0,                       # Lowest Value of Range
                        max = 5,                       # Highest Value of Range
                        value = c(0, 5)),              # Pre-selected values
            
            # Select if number of beds should be color coded
            checkboxInput("bedsColorInput",            # Name of input
                          "Show Bedrooms",             # Display Label
                          value = TRUE),               # Pre-selected value
            
            # Choose Model to fit from Dropdown Menu
            selectInput("model",                       # Name of input
                        "Model Type",                  # Display Label
                        choices = c("None" = "none",   # Available choices in the dropdown
                                    "Linear" = "lm",
                                    "Smooth" = "smooth"))
      ),
      
      # Items to show in the Main Panel
      mainPanel(
            
            # Show Scatterplot
            plotOutput("scatterPlot")
      )
   )
)


# PART 3 - Define server logic required to draw the plot
server <- function(input, output) {
   
   # Define the Plot UI output
   output$scatterPlot <- renderPlot({
         
         # Define my own variables
         minPrice <- input$priceInput[1]
         maxPrice <- input$priceInput[2]
         
         # Filter data based on user input
         filtered <- mydat %>%
               filter(yearly_price >= input$priceInput[1],
                      yearly_price <= input$priceInput[2],
                      area_sqft >= input$areaInput[1],
                      area_sqft <= input$areaInput[2],
                      num_bedrooms >= input$bedsInput[1],
                      num_bedrooms <= input$bedsInput[2]
                      )
         
         # XY Scatter Plot, X = Area, Y = Price
         ## Color Code the bedroom numbers
         if (input$bedsColorInput == TRUE) {
               g <- ggplot(filtered, aes(x = area_sqft, y = yearly_price, color = num_bedrooms)) +
                     geom_point(size = 5, alpha = 0.5) +
                     theme(legend.position="bottom")
         }
         
         ## without bedroom number color coding
         else {
               g <- ggplot(filtered, aes(x = area_sqft, y = yearly_price)) +
                     geom_point(size = 5, alpha = 0.5)
         }
         
         # Plot design elements: title, scale labels etc.
         g <- g + labs(
                     title = "Real Estate Data",
                     subtitle = paste0("Prices from ", formatC(minPrice, big.mark = ","), 
                                       " to ", formatC(maxPrice, big.mark = ","), " AED"),
                     caption = "Source: various real estate websites"
               ) +
               xlab("Area in sqft") + ylab("Yearly Rent in AED") +
               scale_y_continuous(labels = scales::comma) +
               scale_x_continuous(labels = scales::comma)
         
         # Display Model Fit (Line through data)
         ## Linear Model Fit
         if (input$model == "lm") {
               g <- g + geom_smooth(method = "lm")
         }
         
         ## Smooth Model Fit
         else if (input$model == "smooth") {
               g <- g + geom_smooth(method = "loess")
         }
         
         # Display the Plot
         g
   })
}


# PART 4 - Run the application 
shinyApp(ui = ui, server = server)
