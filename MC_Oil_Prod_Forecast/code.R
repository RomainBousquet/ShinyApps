# Title ---------------------------------------------------------------------------------------
# Monte Carlo Oil Production Model
#
# Notes: use beta distribution to create Monte Carlo Simulation to forecast oil production
#
# Inputs: min_prod_well, max_prod_well, shape1, shape2, num_wells
# Outputs: histogram of distribution, CDF, table of percentile results w/ probabilities


# Libraries -----------------------------------------------------------------------------------
library(dplyr)
library(ggplot2)

# Inputs --------------------------------------------------------------------------------------

min_prod_well <- 50       # smallest well production in BOPD
max_prod_well <- 1000     # highest well production in BOPD
shape1 <- 2
shape2 <- 4
num_wells <- 100
runs <- 500


# MC Simulation -------------------------------------------------------------------------------


for (i in c(1:runs)) {
      
}






n <- num_wells * runs
mc <- rbeta(n, shape1 = shape1, shape2 = shape2) 
mc <- data.frame(beta = mc)
mc$Prod <- min_prod_well + (mc$beta * max_prod_well - min_prod_well)

# Calculate CDF
mc$cdf <- mc$Prod
mc$cdf[-1] <- 


# Results -------------------------------------------------------------------------------------
summary(mc)

# Median and Mean Production (per well)
med <- round(median(mc$Prod), 0)
avg <- round(mean(mc$Prod), 0)



# Histogram
g <- ggplot(mc, aes(x = Prod, y=100*(..count..)/sum(..count..))) + 
      geom_histogram() +
      labs(
            title = "Field Production Distribution",
            subtitle = "Simulated distribution"
      ) +
      xlab("Production in BOPD") +
      ylab("Percent Occurance") +
      geom_vline(xintercept = med, color = 'red', size = 2, alpha = 0.4) +
      geom_vline(xintercept = avg, color = 'blue', size = 2, alpha = 0.4)

# Labels
label_med <- paste0("Median Production: ", med, " BOPD")
label_avg <- paste0("Mean Production: ", avg, " BOPD")

y_max <- max(ggplot_build(g)$data[[1]]$ymax)

g + annotate("text",
             label = c(label_med, label_avg),
             x = 650,
             y = c(y_max * 0.95, y_max * 0.9),
             color = c("red", "blue"),
             hjust = 0)

