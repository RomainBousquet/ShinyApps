#
# Downtime for Maintenance Simulation
#
# https://www.steffenruefer.com/?p=518&preview=true
#
#***************************************************************************************************

# Libraries
library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    # Application title
    titlePanel("Downtime for Maintenance"),
    p("Monte Carlo Simulator to determine non-productive time due to mainetance event of an oil or gas well"),
    
    # Sidebar with Generic Simulator Inputs
    sidebarLayout(
        sidebarPanel(
            h4("Input Parameters"),
            tags$hr(),
            
            # Select Single Step Parameters
            radioButtons("single_step", "Set Parameters for: ",
                         c("Failure Detection" = "failure_det",
                           "Assign Investigation Team" = "assign_team",
                           "Root Cause Analysis" = "root_cause",
                           "Propose Solutions" = "propose_sol",
                           "Decide Repair Strategy" = "decide_strategy",
                           "Wait for Repair Slot" = "wait_repair",
                           "Execute Repairs" = "exec_repairs",
                           "Well Startup" = "well_start")),
            
            tags$hr(),
            
            # Show conditional inputs for selected maintenance step
            
            ## Failure Detection Period Parameters
            conditionalPanel(
                condition = "input.single_step == 'failure_det'",
                
                # Choose distribution types
                selectInput("failure_det_dist", "Failure Detection Distribution:",
                            c("Uniform" = "unif",
                              "Normal" = "norm",
                              "Triangle" = "tri"),
                            selected = "tri"
                ),
                
                # Parameters for Uniform Distribution
                conditionalPanel(
                    condition = "input.failure_det_dist == 'unif'",
                    
                    sliderInput("failure_det_unif_range", "Minimum & Maximum (Days):",
                                min = 1, max = 30, value = c(1, 3))
                ),
                
                # Parameters for Normal Distribution
                conditionalPanel(
                    condition = "input.failure_det_dist == 'norm'",
                    
                    sliderInput("failure_det_mean", "Mean (Days):",
                                min = 1, max = 30, value = 2),
                    sliderInput("failure_det_sd", "Standard Deviation (Days):",
                                min = 1, max = 15, value = 1)
                ),
                
                # Parameters for Triangle Distribution
                conditionalPanel(
                    condition = "input.failure_det_dist == 'tri'",
                    
                    sliderInput("failure_det_range", "Minimum & Maximum (Days):",
                                min = 1, max = 30, value = c(1, 6)),
                    sliderInput("failure_det_most_likely", "Most Likely:",
                                min = 1, max = 30, value = 2)
                )
            ),
            
            ## Assign Investigation Team Parameters
            conditionalPanel(
                condition = "input.single_step == 'assign_team'",
                
                # Choose distribution types
                selectInput("assign_team_dist", "Assign Team Distribution:",
                            c("Uniform" = "unif",
                              "Normal" = "norm",
                              "Triangle" = "tri"),
                            selected = "tri"
                ),
                
                # Parameters for Uniform Distribution
                conditionalPanel(
                    condition = "input.assign_team_dist == 'unif'",
                    
                    sliderInput("assign_team_unif_range", "Minimum & Maximum (Days):",
                                min = 1, max = 30, value = c(1, 5))
                ),
                
                # Parameters for Normal Distribution
                conditionalPanel(
                    condition = "input.assign_team_dist == 'norm'",
                    
                    sliderInput("assign_team_mean", "Mean (Days):",
                                min = 1, max = 30, value = 3),
                    sliderInput("assign_team_sd", "Standard Deviation (Days):",
                                min = 1, max = 15, value = 1)
                ),
                
                # Parameters for Triangle Distribution
                conditionalPanel(
                    condition = "input.assign_team_dist == 'tri'",
                    
                    sliderInput("assign_team_range", "Minimum & Maximum (Days):",
                                min = 1, max = 30, value = c(1, 5)),
                    sliderInput("assign_team_most_likely", "Most Likely:",
                                min = 1, max = 30, value = 3)
                )
            ),
            
            ## Root Cause Analysis Parameters
            conditionalPanel(
                condition = "input.single_step == 'root_cause'",
                
                # Choose distribution types
                selectInput("root_cause_dist", "Root Cause Analysis Distribution:",
                            c("Uniform" = "unif",
                              "Normal" = "norm",
                              "Triangle" = "tri"),
                            selected = "norm"
                ),
                
                # Parameters for Uniform Distribution
                conditionalPanel(
                    condition = "input.root_cause_dist == 'unif'",
                    
                    sliderInput("root_cause_unif_range", "Minimum & Maximum (Days):",
                                min = 1, max = 30, value = c(5, 21))
                ),
                
                # Parameters for Normal Distribution
                conditionalPanel(
                    condition = "input.root_cause_dist == 'norm'",
                    
                    sliderInput("root_cause_mean", "Mean (Days):",
                                min = 1, max = 30, value = 10),
                    sliderInput("root_cause_sd", "Standard Deviation (Days):",
                                min = 1, max = 15, value = 4)
                ),
                
                # Parameters for Triangle Distribution
                conditionalPanel(
                    condition = "input.root_cause_dist == 'tri'",
                    
                    sliderInput("root_cause_range", "Minimum & Maximum (Days):",
                                min = 1, max = 30, value = c(5, 21)),
                    sliderInput("root_cause_most_likely", "Most Likely:",
                                min = 1, max = 30, value = 10)
                )
            ),
            
            ## Propose Solutions Parameters
            conditionalPanel(
                condition = "input.single_step == 'propose_sol'",
                
                # Choose distribution types
                selectInput("propose_sol_dist", "Propose Solution Distribution:",
                            c("Uniform" = "unif",
                              "Normal" = "norm",
                              "Triangle" = "tri"),
                            selected = "unif"
                ),
                
                # Parameters for Uniform Distribution
                conditionalPanel(
                    condition = "input.propose_sol_dist == 'unif'",
                    
                    sliderInput("propose_sol_unif_range", "Minimum & Maximum (Days):",
                                min = 1, max = 30, value = c(1, 6))
                ),
                
                # Parameters for Normal Distribution
                conditionalPanel(
                    condition = "input.propose_sol_dist == 'norm'",
                    
                    sliderInput("propose_sol_mean", "Mean (Days):",
                                min = 1, max = 30, value = 4),
                    sliderInput("propose_sol_sd", "Standard Deviation (Days):",
                                min = 1, max = 15, value = 2)
                ),
                
                # Parameters for Triangle Distribution
                conditionalPanel(
                    condition = "input.propose_sol_dist == 'tri'",
                    
                    sliderInput("propose_sol_range", "Minimum & Maximum (Days):",
                                min = 1, max = 30, value = c(1, 6)),
                    sliderInput("propose_sol_most_likely", "Most Likely:",
                                min = 1, max = 30, value = 4)
                )
            ),
            
            ## Decide on Repair Strategy Parameters
            conditionalPanel(
                condition = "input.single_step == 'decide_strategy'",
                
                # Choose distribution types
                selectInput("decide_strategy_dist", "Decide on Repair Strategy Distribution:",
                            c("Uniform" = "unif",
                              "Normal" = "norm",
                              "Triangle" = "tri"),
                            selected = "tri"
                ),
                
                # Parameters for Uniform Distribution
                conditionalPanel(
                    condition = "input.decide_strategy_dist == 'unif'",
                    
                    sliderInput("decide_strategy_unif_range", "Minimum & Maximum (Days):",
                                min = 1, max = 30, value = c(1, 14))
                ),
                
                # Parameters for Normal Distribution
                conditionalPanel(
                    condition = "input.decide_strategy_dist == 'norm'",
                    
                    sliderInput("decide_strategy_mean", "Mean (Days):",
                                min = 1, max = 30, value = 8),
                    sliderInput("decide_strategy_sd", "Standard Deviation (Days):",
                                min = 1, max = 15, value = 3)
                ),
                
                # Parameters for Triangle Distribution
                conditionalPanel(
                    condition = "input.decide_strategy_dist == 'tri'",
                    
                    sliderInput("decide_strategy_range", "Minimum & Maximum (Days):",
                                min = 1, max = 30, value = c(1, 14)),
                    sliderInput("decide_strategy_most_likely", "Most Likely:",
                                min = 1, max = 30, value = 8)
                )
            ),
            
            ## Wait for repair slot Parameters
            conditionalPanel(
                condition = "input.single_step == 'wait_repair'",
                
                # Choose distribution types
                selectInput("wait_repair_dist", "Waiting on Repair Slot Distribution:",
                            c("Uniform" = "unif",
                              "Normal" = "norm",
                              "Triangle" = "tri"),
                            selected = "tri"
                ),
                
                # Parameters for Uniform Distribution
                conditionalPanel(
                    condition = "input.wait_repair_dist == 'unif'",
                    
                    sliderInput("wait_repair_unif_range", "Minimum & Maximum (Days):",
                                min = 1, max = 30, value = c(5, 30))
                ),
                
                # Parameters for Normal Distribution
                conditionalPanel(
                    condition = "input.wait_repair_dist == 'norm'",
                    
                    sliderInput("wait_repair_mean", "Mean (Days):",
                                min = 1, max = 30, value = 15),
                    sliderInput("wait_repair_sd", "Standard Deviation (Days):",
                                min = 1, max = 15, value = 5)
                ),
                
                # Parameters for Triangle Distribution
                conditionalPanel(
                    condition = "input.wait_repair_dist == 'tri'",
                    
                    sliderInput("wait_repair_range", "Minimum & Maximum (Days):",
                                min = 1, max = 30, value = c(5, 30)),
                    sliderInput("wait_repair_most_likely", "Most Likely:",
                                min = 1, max = 30, value = 15)
                )
            ),
            
            ## Execute Repairs Parameters
            conditionalPanel(
                condition = "input.single_step == 'exec_repairs'",
                
                # Choose distribution types
                selectInput("exec_repairs_dist", "Execute Repairs Distribution:",
                            c("Uniform" = "unif",
                              "Normal" = "norm",
                              "Triangle" = "tri"),
                            selected = "tri"
                ),
                
                # Parameters for Uniform Distribution
                conditionalPanel(
                    condition = "input.exec_repairs_dist == 'unif'",
                    
                    sliderInput("exec_repairs_unif_range", "Minimum & Maximum (Days):",
                                min = 1, max = 30, value = c(2, 15))
                ),
                
                # Parameters for Normal Distribution
                conditionalPanel(
                    condition = "input.exec_repairs_dist == 'norm'",
                    
                    sliderInput("exec_repairs_mean", "Mean (Days):",
                                min = 1, max = 30, value = 7),
                    sliderInput("exec_repairs_sd", "Standard Deviation (Days):",
                                min = 1, max = 15, value = 3)
                ),
                
                # Parameters for Triangle Distribution
                conditionalPanel(
                    condition = "input.exec_repairs_dist == 'tri'",
                    
                    sliderInput("exec_repairs_range", "Minimum & Maximum (Days):",
                                min = 1, max = 30, value = c(2, 15)),
                    sliderInput("exec_repairs_most_likely", "Most Likely:",
                                min = 1, max = 30, value = 7)
                )
            ),
            
            ## Well Startup Parameters
            conditionalPanel(
                condition = "input.single_step == 'well_start'",
                
                # Choose distribution types
                selectInput("well_start_dist", "Well Startup Distribution:",
                            c("Uniform" = "unif",
                              "Normal" = "norm",
                              "Triangle" = "tri"),
                            selected = "unif"
                ),
                
                # Parameters for Uniform Distribution
                conditionalPanel(
                    condition = "input.well_start_dist == 'unif'",
                    
                    sliderInput("well_start_unif_range", "Minimum & Maximum (Days):",
                                min = 1, max = 30, value = c(1, 5))
                ),
                
                # Parameters for Normal Distribution
                conditionalPanel(
                    condition = "input.well_start_dist == 'norm'",
                    
                    sliderInput("well_start_mean", "Mean (Days):",
                                min = 1, max = 30, value = 3),
                    sliderInput("well_start_sd", "Standard Deviation (Days):",
                                min = 1, max = 15, value = 1)
                ),
                
                # Parameters for Triangle Distribution
                conditionalPanel(
                    condition = "input.well_start_dist == 'tri'",
                    
                    sliderInput("well_start_range", "Minimum & Maximum (Days):",
                                min = 1, max = 30, value = c(1, 10)),
                    sliderInput("well_start_most_likely", "Most Likely:",
                                min = 1, max = 30, value = 3)
                )
            ),
            
            # 'Run MCS' Action Button
            tags$hr(),
            actionButton("run_MCS", "Run Simulation")
            
        ),
        
        # Main Panel Contents
        
        mainPanel(
            tabsetPanel(type = "tabs",
                        
                    # Well Model (input) Tab Panel
                    tabPanel("Inputs",
                         # Explanation of this tab
                         h3("Input Parameters / Distributions"),
                         p("Distribution and related parameters for each maintenance step. Set 
                            parameters as deemed appropriate or as per user case. You can also 
                            accept the defaults and start experimenting."),
                         tags$hr(),
                         
                         h4("Sequence of Maintenance Steps Plot"),
                         plotOutput("sequence_plot")
                         
                    ),
                    
                    # Output Tab Panel
                    tabPanel("Results",
                        h3("Simulation Results"),
                    
                        # Maintenance Duration Distribution Plot
                        h4("Maintenance Duration Distribution Plot"),
                        plotOutput("duration_distr_plot"),
                        
                        # CDF Curve
                        h4("Cumulative Distribution Plot"),
                        plotOutput("cdf_plot")
                        
                        
                    )
                        
            ))
    )))
