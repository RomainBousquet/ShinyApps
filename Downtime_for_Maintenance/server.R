#
# Downtime for Maintenance Simulation
#
# https://www.steffenruefer.com/?p=518&preview=true
#
#***************************************************************************************************
#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(ggplot2)
library(triangle)

# Define server logic
shinyServer(function(input, output) {
    
    # Action Button
    v <- reactiveValues(doMCS = FALSE)
    
    observeEvent(input$go, {
        # 0 will be coerced to FALSE
        # 1+ will be coerced to TRUE
        v$doMCS <- input$run_MCS
    })
    
    # Create input dataframe
    input_df <- reactive({
        
        # Build standard columns to start with
        ## ID column - there are 8 rows, one for each maintenance step
        id <- c(1:8)
        
        ## Description / Task
        descr <- c("1- Failure detected",
                  "2- Assign Investigation Team",
                  "3- Root Cause Analysis",
                  "4- Propose Solutions",
                  "5- Decide on Repair Strategy",
                  "6- Wait for Repair Slot",
                  "7- Execute Repairs",
                  "8- Well Startup")
        
        ## Type of task - this is mainly for coloring the waterfall plot
        type <- c("Design Phase",
                  "Design Phase",
                  "Design Phase",
                  "Design Phase",
                  "Design Phase",
                  "Waiting Time",
                  "Repair Phase",
                  "Resume Prod Phase")
        
        ## Selected distribution
        distr <- c(input$failure_det_dist,
                   input$assign_team_dist,
                   input$root_cause_dist,
                   input$propose_sol_dist,
                   input$decide_strategy_dist,
                   input$wait_repair_dist,
                   input$exec_repairs_dist,
                   input$well_start_dist)
        
        ## Unif_Minimum
        unif_min <- c(input$failure_det_unif_range[1],
                      input$assign_team_unif_range[1],
                      input$root_cause_unif_range[1],
                      input$propose_sol_unif_range[1],
                      input$decide_strategy_unif_range[1],
                      input$wait_repair_unif_range[1],
                      input$exec_repairs_unif_range[1],
                      input$well_start_unif_range[1])
        
        ## Unif_Maximum
        unif_max <- c(input$failure_det_unif_range[2],
                      input$assign_team_unif_range[2],
                      input$root_cause_unif_range[2],
                      input$propose_sol_unif_range[2],
                      input$decide_strategy_unif_range[2],
                      input$wait_repair_unif_range[2],
                      input$exec_repairs_unif_range[2],
                      input$well_start_unif_range[2])
        
        ## Mean
        n_mean <- c(input$failure_det_mean,
                    input$assign_team_mean,
                    input$root_cause_mean,
                    input$propose_sol_mean,
                    input$decide_strategy_mean,
                    input$wait_repair_mean,
                    input$exec_repairs_mean,
                    input$well_start_mean)
        
        ## Standard Dev
        n_sd <- c(input$failure_det_sd,
                    input$assign_team_sd,
                    input$root_cause_sd,
                    input$propose_sol_sd,
                    input$decide_strategy_sd,
                    input$wait_repair_sd,
                    input$exec_repairs_sd,
                    input$well_start_sd)
        
        ## Tri_Minimum
        tri_min <- c(input$failure_det_range[1],
                      input$assign_team_range[1],
                      input$root_cause_range[1],
                      input$propose_sol_range[1],
                      input$decide_strategy_range[1],
                      input$wait_repair_range[1],
                      input$exec_repairs_range[1],
                      input$well_start_range[1])
        
        ## Tri_Maximum
        tri_max <- c(input$failure_det_range[2],
                     input$assign_team_range[2],
                     input$root_cause_range[2],
                     input$propose_sol_range[2],
                     input$decide_strategy_range[2],
                     input$wait_repair_range[2],
                     input$exec_repairs_range[2],
                     input$well_start_range[2])
        
        ## Most_Likely
        most_likely <- c(input$failure_det_most_likely,
                         input$assign_team_most_likely,
                         input$root_cause_most_likely,
                         input$propose_sol_most_likely,
                         input$decide_strategy_most_likely,
                         input$wait_repair_most_likely,
                         input$exec_repairs_most_likely,
                         input$well_start_most_likely)

        # Add additional Columns for plot
        ## Width, X_Start, X_End
        width <- c(0, 0, 0, 0, 0, 0, 0, 0)
        x_start <- c(0, 0, 0, 0, 0, 0, 0, 0)
        x_end <- c(0, 0, 0, 0, 0, 0, 0, 0)
        
        ## Loop
        for (i in c(1:8)) {
            
            # Check on most_likely input validity
            if (most_likely[i] > tri_max[i]) most_likely[i] = tri_max[i]
            if (most_likely[i] < tri_min[i]) most_likely[i] = tri_min[i]
            
            # Set / calculate width (means average), depending on selected distribution
            if (distr[i] == "unif") {
                width[i] <- (unif_max[i] + unif_min[i]) / 2
            }
            else if (distr[i] == "norm") {
                width[i] <- n_mean[i]
            }
            else {
                width[i] <- most_likely[i]
            }
            
            # Calculate x_start and x_end
            if (i == 1) {
                x_start[i] = 0
                x_end[i] = width[i]
            }
            else {
                x_start[i] = x_end[i-1]
                x_end[i] = x_start[i] + width[i]
            }
            
        }
        
        # Create data frame from columns
        df <- data.frame(id = id,
                         task = descr,
                         type = type,
                         distr = distr,
                         unif_min = unif_min,
                         unif_max = unif_max,
                         mean = n_mean,
                         sd = n_sd,
                         tri_min = tri_min,
                         tri_max = tri_max,
                         most_likely = most_likely,
                         width = width,
                         x_start = x_start,
                         x_end = x_end)
        
        # Convert into tibble
        input_df <- tbl_df(df)
        
    })
    
    # Render input_df as table - for test purpose only
    output$test_df <- renderTable({
        
        df <- input_df()
        df
        
    })

    # Maintenance Sequence Plot - Waterfall-like plot
    output$sequence_plot <- renderPlot({
        
        # Load data
        df <- input_df()
        estimate <- df$x_end[8]
        
        # Flip order of tasks
        flevels <- levels(df$task)
        flevels <- rev(flevels)
        
        # Draw Plot
        cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
        ggplot(df, aes(y = task, fill = type)) +
            geom_rect(aes(y = task,
                          xmin = x_start,
                          xmax = x_end,
                          ymin = 9 - id - 0.45,
                          ymax = 9 - id + 0.45)) +
            labs(
                title = paste0("Maintenance Sequence of Events - Estimated ", estimate, " days"),
                subtitle = "Asset Failure: average number of days duration for each maintenance step"
            ) +
            ylab("Maintenance Step") +
            xlab("Duration (Days)") +
            scale_fill_manual(values=cbPalette) +
            scale_y_discrete(limits=flevels) +
            guides(fill=guide_legend(title=NULL)) +
            theme(legend.position="bottom")
        
    })
    
    # Calculate MCS
    mcs_df <- eventReactive(input$run_MCS, {
        
        # Load input data
        df <- input_df()
        
        # Number of simulations (fixed)
        runs <- 5000
        
        # Init - total maintenance days
        total_days <- c()
        
        # Loop through each maintenance step
        for (i in c(1:8)) {
            
            # Take samples as per inputs
            if (df$distr[i] == "unif") {
                d <- round(runif(runs, df$unif_min[i], df$unif_max[i]), 1)
            }
            else if (df$distr[i] == "norm") {
                d <- round(rnorm(runs, df$mean[i], df$sd[i]), 1)
                d[d<0.5] <- 0.5       # half day set as minimum duration
            }
            else {
                d <- round(rtriangle(runs, df$tri_min[i], df$tri_max[i]))
            }
            
            # Add to total days
            if (is.null(total_days)) {
                total_days <- d
            }
            else {
                total_days <- total_days + d
            }
            
        }
        
        # Convert to single feature data frame
        data.frame(duration = total_days)
        
    })
    
    # Duration Distribution Plot
    output$duration_distr_plot <- renderPlot({
        
        # Set data frame, calculate additional data
        df <- mcs_df()
        avg <- round(mean(df$duration, na.rm = TRUE), 0)
        q05 <- round(quantile(df$duration, 0.05))
        q95 <- round(quantile(df$duration, 0.95))
        
        # Plot
        ggplot(df, aes(x = duration, y=100*(..count..)/sum(..count..))) + 
            geom_histogram(bins = 50) +
            labs(
                title = paste0("Average Maintenance Duration: ",
                               format(avg, big.mark = ","), " Days"),
                subtitle = "Monte Carlo with 5,000 simulations"
            ) +
            xlab("Maintenance Duration in Days") +
            ylab("Occurance Percentage") +
            geom_vline(xintercept = avg, size = 1, color = 'deepskyblue1', alpha = 0.8) +
            geom_vline(xintercept = c(q05, q95), size = 1, color = 'deepskyblue1', 
                       alpha = 0.5, linetype = "dashed")
        
    })
    
    # CDF Plot
    output$cdf_plot <- renderPlot({
        
        # Set data frame, calculate additional data
        df <- mcs_df()
        avg <- round(mean(df$duration, na.rm = TRUE), 0)
        q05 <- round(quantile(df$duration, 0.05), 0)
        q95 <- round(quantile(df$duration, 0.95), 0)
        
        ggplot(df, aes(x = duration)) + 
            stat_ecdf(geom = "step", pad = FALSE, size = 1) +
            geom_hline(yintercept = c(0,1), size = 1, linetype = "dotted") +
            labs(
                title = "Uncertainty in Maintenance Duration",
                subtitle = paste0("90% Probability that downtime is between ",
                                  format(q05, big.mark = ","), " days and ", 
                                  format(q95, big.mark = ","), " days")
            ) +
            scale_y_continuous(labels = scales::percent, 
                               breaks = seq(0, 1, 0.1)) +
            xlab("Total Downtime in Days") +
            ylab("Probability of downtime being lower than indicated") +
            geom_vline(xintercept = avg, size = 1, color = 'deepskyblue1', alpha = 0.8) +
            geom_vline(xintercept = c(q05, q95), size = 1, color = 'deepskyblue1', 
                       alpha = 0.5, linetype = "dashed") +
            annotate("rect", xmin = q05, xmax = q95, ymin = 0, ymax = 1, 
                     fill = 'deepskyblue1', alpha = 0.1)
        
    })
    
  
})
