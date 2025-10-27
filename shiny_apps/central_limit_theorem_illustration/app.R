# Central limit theorem Illustration:

library(shiny)
library(ggplot2)

ui <- fluidPage(
    titlePanel("Central Limit Theorem Illustration"),

    sidebarLayout(
        sidebarPanel(
            selectInput("dist", "Choose Population Distribution:",
                        choices = c("Uniform", "Exponential", "Normal")),
            numericInput("n", "Sample size (n):", value = 30, min = 1, step = 1),
            numericInput("samples", "Number of samples:", value = 1000, min = 1, step = 1),
            actionButton("simulate", "Simulate"),

            fluidRow(
                h4(strong("Central Limit Theroem:")),
                p(
                    "Central Limite Therom states that, no matter what distribution we sample from, the sample distribution of a metric would tend to",
                    strong("Normal Distribution"),
                    "as sample sample size grows.",
                    br(),
                    h5(strong("How to use the App?")),
                    "Pick the distribution from the drop down menu. In the current version, Uniform, Exponential, and Normal distribution are available.The parameters for
                    these distribution are set to default values as available in thier native R-function. For instance, in normal distriution mean = 0 and variance = 1. Then input
              the sample size (n). By default it is set to 30. Finally input he number of samples, basically it will sample from the user picked distribution - number of
              times the user supplied input. By default, it is set to 1000, in this version. The simulate button will do the calculte the sampling distribution of the
              sample means and plot the barchart in the second pane of the visual page.",
                )
            )
        ),

        mainPanel(
            h4("Population Distribution"),
            plotOutput("popPlot"),
            br(),
            h4("Distribution of Sample Means"),
            plotOutput("meanPlot")
        )
    ),


)

server <- function(input, output) {

    population <- reactive({
        dist <- input$dist
        size <- input$n * input$samples # size of the population

        switch(dist,
               "Uniform" = runif(size, min = 0, max = 1),
               "Exponential" = rexp(size, rate = 1),
               "Normal" = rnorm(size, mean = 0, sd = 1))
    })

    sample_means <- eventReactive(input$simulate, {
        dist <- input$dist
        n <- input$n
        samples <- input$samples

        means <- numeric(samples)

        for (i in 1:samples) {
            x <- switch(dist,
                        "Uniform" = runif(n, 0, 1),
                        "Exponential" = rexp(n, 1),
                        "Normal" = rnorm(n, 0, 1))
            means[i] <- mean(x)
        }
        means
    })

    output$popPlot <- renderPlot({
        ggplot(data.frame(x = population()), aes(x = x)) +
            geom_histogram(bins = 30, fill = "steelblue", color = "white") +
            theme_minimal() +
            labs(x = "Value", y = "Frequency", title = paste("Population Distribution:", input$dist))
    })

    output$meanPlot <- renderPlot({
        req(sample_means())
        ggplot(data.frame(means = sample_means()), aes(x = means)) +
            geom_histogram(bins = 30, fill = "tomato", color = "white") +
            theme_minimal() +
            labs(x = "Sample Mean", y = "Frequency", title = paste("Distribution of Sample Means (n =", input$n, ")"))
    })

}

shinyApp(ui = ui, server = server)

