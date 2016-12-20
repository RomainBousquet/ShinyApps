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
runs <- 10000


# MC Simulation -------------------------------------------------------------------------------

sims <- c()
total_prod <- c()
for (i in c(1:runs)) {
      
      beta <- sort(rbeta(num_wells, shape1 = shape1, shape2 = shape2))
      well_prod <- min_prod_well + (beta * max_prod_well - min_prod_well)
      
      if (is.null(sims)) {
            sims <- well_prod
            total_prod <- sum(well_prod)
      } else {
            sims <- sims + well_prod
            total_prod <- append(total_prod, sum(well_prod))
      }
}
sims <- round( sims / runs, 1)
mc <- data.frame(Prod = sims)
ggplot(mc, aes(x = Prod)) + geom_histogram()

prod_df <- data.frame(total = total_prod)
ggplot(prod_df, aes(x = total)) + geom_histogram()


prob <- 0.1
prod_prob <- round(quantile(total_prod, prob), 0)

plot_expl <- paste0("There is a \n", prob * 100, "% Probability \n",
                    "of producing less than \n", prod_prob, " BOPD.")

ggplot(prod_df, aes(x = total)) + 
      stat_ecdf(geom = "step", pad = FALSE, size = 1) +
      geom_vline(xintercept = prod_prob, 
                 size = 2, 
                 color = 'blue',
                 alpha = 0.5) +
      geom_hline(yintercept = prob, size = 1, linetype = "dashed",
                 color = "blue") +
      annotate("text", label = plot_expl,
               x = min(total_prod), y = 0.9,
               color = 'blue', hjust = 0, size = 6, vjust = 1) +
      annotate("rect",
               xmin = prod_prob, xmax = max(total_prod),
               ymin = 0, ymax = 1,
               fill = 'blue', alpha = 0.1) +
      geom_hline(yintercept = c(0,1), size = 1, linetype = "dotted") +
      labs(
            title = "Uncertainty in Daily Production",
            subtitle = "Probability that Daily Production falls below a certain value"
      ) +
      scale_y_continuous(labels = scales::percent, 
                         breaks = seq(0, 1, 0.1)) +
      xlab("Total Daily Production in BOPD") +
      ylab("Probability of Daily Production being lower than indicated")




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





x <- seq(0, 1, length=1000)
prod <- seq(50, 1000, length = 1000)
df_beta <- data.frame(x = prod, beta = dbeta(x, 2, 2))

ggplot(df_beta, aes(x = prod, y = beta)) + geom_line(size = 1.5, color = "blue")


min_prod_well <- 50
max_prod_well <- 1000

set.seed(1235)
beta <- sort(rbeta(50000, shape1 = 2, shape2 = 5))
well_prod <- 2*min_prod_well + (beta * max_prod_well - min_prod_well)

df <- data.frame(Production = well_prod)

ggplot(df, aes(x = Production)) + 
      geom_density(fill = "blue", alpha = 0.3) +
      labs(
            title = "Production Distribution Plot",
            subtitle = "Based on randomized beta distribution"
      ) +
      ylab("Density") + xlab("Single Well Production in BOPD") +
      scale_y_continuous(labels = scales::percent) +
      scale_x_continuous(breaks = seq(50, 1000, 50))

summary(df)


