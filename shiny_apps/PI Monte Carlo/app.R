# app.R
library(shiny)
library(dplyr)

#  the pi_value function for the shiny app
pi_value <- function(sample_size = 10000, sim = 100, plot = TRUE) {
    pi_values <- rep(0, sim)

    for (i in 1:sim) {
        df <- data.frame(

            # sampling from uniform distribution [0,1]
            x = runif(n = sample_size, min = 0, max = 1),
            y = runif(n = sample_size, min = 0, max = 1)
        )
        df <- df %>%
            mutate(ct_pt = ifelse(y^2 <= 1 - x^2, 1, 0))
        pie_est <- 4 * (sum(df$ct_pt) / sample_size)
        pi_values[i] <- pie_est
    }

    results <- list(
        pie = mean(pi_values),
        sd = sd(pi_values),
        bias = mean(pi_values) - pi,
        absolute_error = abs(pi - mean(pi_values)),
        relative_error = abs(pi - mean(pi_values)) / pi
    )

    if (plot) {
        # generate the data frame for the last simulation for plotting
        df <- data.frame(
            x = runif(n = sample_size, min = 0, max = 1),
            y = runif(n = sample_size, min = 0, max = 1)
        ) %>%
            mutate(ct_pt = ifelse(y^2 <= 1 - x^2, 1, 0))

        list(plot_df = df, results = results)
    } else {
        list(results = results)
    }
}

# ui/ user interface
ui <- fluidPage(
    titlePanel("Monte Carlo Simulation for Pi"),

    # Sidebar with user inputs
    sidebarLayout(
        sidebarPanel(
            h4("Monte Carlo Simulation:"),
            p("The Monte Carlo method uses repeated random sampling to obtain numerical results. In this app, it estimates the value of Pi by simulating random points within a square and checking how many fall inside an inscribed circle."),

            hr(),

            h4("Simulation Parameters"),
            numericInput("sample_size",
                         "Number of points per simulation:",
                         value = 10000,
                         min = 100,
                         max = 100000),

            numericInput("sim",
                         "Number of simulations:",
                         value = 100,
                         min = 1,
                         max = 500),

            checkboxInput("plot",
                          "Display the last simulation's plot?",
                          value = TRUE)
        ),

        # Main panel for displaying output
        mainPanel(
            h4("Simulation Results"),
            verbatimTextOutput("results"),
            plotOutput("plot")
        )
    )
)

# server/ backend
server <- function(input, output) {
    # reactive expression to run the simulation
    simulation_output <- reactive({
        req(input$sample_size, input$sim)
        pi_value(sample_size = input$sample_size, sim = input$sim, plot = input$plot)
    })

    # Render the simulation results as text
    output$results <- renderPrint({
        sim_data <- simulation_output()

        # status of bias
        estimation_status <- ifelse(sim_data$results$bias > 0, "overestimated",
                                    ifelse(sim_data$results$bias < 0, "underestimated", "unbiased"))

        cat("Simulation Results:\n")
        cat("--------------------\n")
        cat("Estimated Pi (mean):\t", sim_data$results$pie, "\n")
        cat("True Pi Value:\t\t", pi, "\n")
        cat("Standard Deviation:\t", sim_data$results$sd, "\n")
        cat("Bias:\t\t\t", sim_data$results$bias,"(", estimation_status ,")", "\n")
        cat("Absolute Error:\t\t", sim_data$results$absolute_error, "\n")
        cat("Relative Error:\t\t", sim_data$results$relative_error, "\n")

    })

    # Render the plot if the checkbox is checked
    output$plot <- renderPlot({
        if (input$plot) {
            sim_data <- simulation_output()
            plot_df <- sim_data$plot_df

            plot(x = plot_df$x, y = plot_df$y,
                 col = ifelse(plot_df$ct_pt == 1, "green", "red"),
                 main = paste(" Monte Carlo Simulation (Last Run)",
                              "n =", input$sample_size),
                 xlab = "x", ylab = "y", pch = 20)
            curve(sqrt(1 - x^2), 0, 1, add = TRUE, col = "blue", lwd = 2)
        }
    })
}

# Run the application
shinyApp(ui = ui, server = server)

