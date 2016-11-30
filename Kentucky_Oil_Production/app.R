library(shiny)
library(leaflet)
library(RColorBrewer)
library(dplyr)
library(scales)

df <- read.csv("wells.csv")
df$rad <- 5 + sqrt(df$prod)/4

ui <- bootstrapPage(
      tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
      tags$head(
            # Include our custom CSS
            includeCSS("styles.css")
      ),
      
      leafletOutput("map", width = "100%", height = "100%"),
      absolutePanel(id = "controls", top = 20, right = 20,
                    fixed = TRUE, draggable = TRUE,
                    left = "auto", bottom = "auto",
                    width = 250, height = "auto",
                    h2("Controls"),
                    selectInput("colors", "Color Scheme",
                                rownames(subset(brewer.pal.info, category %in% c("seq", "div")))
                    ),
                    checkboxInput("cluster", "Show Clusters", FALSE),
                    checkboxInput("legend", "Show legend", TRUE),
                    hr(),
                    strong("BBL / year:"),
                    p(textOutput("total_prod")),
                    strong("Wells:"),
                    p(textOutput("visible_wells"))
      )
)

server <- function(input, output, session) {
      
      # This reactive expression represents the palette function,
      # which changes as the user makes selections in UI.
      colorpal <- reactive({
            colorNumeric(input$colors, df$prod)
      })
      
      # Calculate Total Production
      output$total_prod <- renderText({
            
            if (is.null(input$map_bounds))
                  return(0)
            bounds <- input$map_bounds
            latRng <- range(bounds$north, bounds$south)
            lngRng <- range(bounds$east, bounds$west)

            filtered <- df %>%
                  filter(Lat >= latRng[1], Lat <= latRng[2],
                         Lng >= lngRng[1], Lng <= lngRng[2])

            format( sum(filtered$prod), big.mark = "," )

      })
      
      output$visible_wells <- renderText({
            
            if (is.null(input$map_bounds))
                  return(0)
            bounds <- input$map_bounds
            latRng <- range(bounds$north, bounds$south)
            lngRng <- range(bounds$east, bounds$west)
            
            filtered <- df %>%
                  filter(Lat >= latRng[1], Lat <= latRng[2],
                         Lng >= lngRng[1], Lng <= lngRng[2])
            
            nrow(filtered)
            
      })
      
      output$map <- renderLeaflet({
            # Use leaflet() here, and only include aspects of the map that
            # won't need to change dynamically (at least, not unless the
            # entire map is being torn down and recreated).
            leaflet(df) %>% addTiles() %>%
                  fitBounds(~min(Lng), ~min(Lat), ~max(Lng), ~max(Lat))
      })
      
      # Incremental changes to the map (in this case, replacing the
      # circles when a new color is chosen) should be performed in
      # an observer. Each independent set of things that can change
      # should be managed in its own observer.
      observe({
            pal <- colorpal()
            
            if (input$cluster) {
                  leafletProxy("map", data = df) %>%
                        clearMarkers() %>%
                        addCircleMarkers(radius = 5 + sqrt(df$prod)/4, weight = 1, color = "#777777",
                                         fillColor = ~pal(prod), fillOpacity = 0.5,
                                         popup = ~paste0("Yearly Prod: <b>", prod,
                                                         "</b> bbl<br/> Formation: ", Formation),
                                         clusterOptions = markerClusterOptions()
                        )
            }
            else {
                  leafletProxy("map", data = df) %>%
                        clearMarkers() %>%
                        clearMarkerClusters() %>%
                        addCircleMarkers(radius = 5 + sqrt(df$prod)/4, weight = 1, color = "#777777",
                                         fillColor = ~pal(prod), fillOpacity = 0.5, 
                                         popup = ~paste0("Yearly Prod: <b>", prod,
                                                        "</b> bbl<br/> Formation: ", Formation)
                        )
            }
            
      })
      
      # Use a separate observer to recreate the legend as needed.
      observe({
            proxy <- leafletProxy("map", data = df)
            
            # Remove any existing legend, and only if the legend is
            # enabled, create a new one.
            proxy %>% clearControls()
            if (input$legend) {
                  pal <- colorpal()
                  proxy %>% addLegend(position = "bottomright",
                                      pal = pal, values = ~prod,
                                      title = "Production / Year"
                  )
            }
      })
}

shinyApp(ui, server)