library(shiny)
library(readxl)
library(ggplot2)
library(shinythemes)
library(rjags)

#g1 <- readRDS(here::here("data/g1.RDS"))
g1<-readRDS(here::here("g1.RDS"))
# Define UI
ui <- fluidPage(
  titlePanel("Compare Hedges' g"),
  
  # Introduction page
  tabsetPanel(
    tabPanel("Introduction",
             tags$div(
               h2("Welcome to the Hedges' g Comparison App for ecological studies"),
               p("This app allows you to compare Hedges' g values from your dataset with a provided dataset of ecological effect sizes."),
               p("The provided dataset comes from Fox (2020) which contains effect sizes (Hedges g) from 8396 studies. There are several clear outliers in the dataset (Effect sizes over 100 for example), so I used the first and third quartiles to identify and remove any outliers resulting in 7436 effect sizes"),
               p("To get started, upload your data file and select the column containing Hedges' g values."),
               p("You can upload CSV, XLS, or XLSX files."),
               p("After uploading your data, select the column containing Hedges' g values and then press 'Go'."),
               p("You will see a comparison plot between your data and the provided dataset."),
               br(),
               p("References"),
               br(),
               p("Fox, J. W. (2022). How much does the typical ecological meta-analysis overestimate the true mean effect size? Ecology and Evolution, 12, e9521. https://doi.org/10.1002/ece3.9521")
             )
    ),
    
    # Main content page
    tabPanel("Comparison",
             sidebarLayout(
               sidebarPanel(
                 fileInput("file", "Upload Data File", accept = c(".csv", ".xls", ".xlsx")),
                 br(),
                 selectInput("column", "Select Hedges' g Column", choices = NULL),
                 br(),
                 actionButton("go_button", "Go", icon = icon("refresh")),
                 br()
               ),
               mainPanel(
                plotly::plotlyOutput("comparison_plot", height = "500px"),
                 br(),
                 p("It takes a couple of minutes to run the model. The red lines on the plot are the effect sizes in the uploaded dataset and the blue distribution is the typical effect sizes in ecological studies. If your effect sizes fall out of this distribution it is useful to double check your Hedges g calculation.")
               )
             )
    )
  ),
  
  theme = shinytheme("flatly")
)

# Define server logic
server <- function(input, output, session) {
  # Read uploaded data
  data <- reactive({
    req(input$file)
    inFile <- input$file
    file_extension <- tools::file_ext(inFile$name)
    
    if (file_extension %in% c("xls", "xlsx")) {
      data <- read_excel(inFile$datapath, format = file_extension)
    } else if (file_extension == "csv") {
      data <- read.csv(inFile$datapath)
    } else {
      stop("Unsupported file format. Please upload a CSV, XLS, or XLSX file.")
    }
    
    updateSelectInput(session, "column", choices = colnames(data))
    return(data)
  })
  
  # Update column choices dynamically
  observeEvent(input$file, {
    req(input$file)
    inFile <- input$file
    file_extension <- tools::file_ext(inFile$name)
    
    if (file_extension %in% c("xls", "xlsx")) {
      data <- read_excel(inFile$datapath, format = file_extension)
    } else if (file_extension == "csv") {
      data <- read.csv(inFile$datapath)
    } else {
      stop("Unsupported file format. Please upload a CSV, XLS, or XLSX file.")
    }
    
    updateSelectInput(session, "column", choices = colnames(data))
  })
  
  # Generate comparison plot
  output$comparison_plot <- renderPlot({
    # Placeholder plot
    plot(1, type = "n", xlab = "", ylab = "", main = "Comparison Plot")
  })
  
  # Go button event
  observeEvent(input$go_button, {
    req(input$file)
    req(input$column)
    
    g2 <- data()[[input$column]]
    
    # JAGS model fitting
    model_string <- "
    model {
        for (i in 1:N) {
            g[i] ~ dnorm(mu, tau)
        }
        mu ~ dnorm(0, 0.01)
        tau ~ dgamma(0.01, 0.01)
        sigma <- 1 / sqrt(tau)
    }
  "
    
    data_jags <- list(g = g1, N = length(g1))
    inits <- function() {
      list(mu = rnorm(1, 0, 1), tau = rgamma(1, 1, 1))
    }
    model_jags <- jags.model(textConnection(model_string), data = data_jags, inits = inits, n.chains = 4)
    update(model_jags, 1000)  # Burn-in
    
    # Generate posterior predictive distributions
    posterior_samples <- coda.samples(model_jags, variable.names = c("mu", "tau"), n.iter = 5000)
    mu_samples <- posterior_samples[[1]][,"mu"]
    tau_samples <- posterior_samples[[1]][,"tau"]
    
    # Generate posterior predictive samples for g2
    g2_posterior_predictive <- matrix(NA, nrow = length(g2), ncol = length(mu_samples))
    for (i in 1:length(mu_samples)) {
      g2_posterior_predictive[, i] <- rnorm(length(g2), mean = mu_samples[i], sd = 1 / sqrt(tau_samples[i]))
    }
    
    # Convert to data frame for plotting
    g2_posterior_predictive_df <- as.data.frame(g2_posterior_predictive)
    
    # Plot Results
    output$comparison_plot <-plotly::renderPlotly({
      p<- ggplot(g2_posterior_predictive_df, aes(x = V1)) +
        geom_vline(xintercept = g2, colour = "red") +
        geom_density(fill = "skyblue", alpha = 0.7) +
        labs(x = "Hedges' g", y = "Density", title = "Posterior Predictive Distribution for Hedges' g in Dataset 2") +
        theme_minimal()
      
      plotly::ggplotly(p)
    })
  })
  
}
# Run the Shiny app
shinyApp(ui, server)
