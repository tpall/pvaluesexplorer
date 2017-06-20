
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(theme = "bootstrap.css",
  
  # Application title
  titlePanel("P value histogram-based retrospective power"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    
    sidebarPanel(
      
      # Select file dialog
      fileInput(inputId = "infile",
                label = "Choose your 'toptable'/'toptag' file with P values in regular delimited format (e.g. csv):",
                accept = c(
                  "text/csv",
                  "text/comma-separated-values,text/plain",
                  ".csv")),
      tags$hr(),
      
      # Select number of histogram bins
      sliderInput("bins",
                  "Number of histogram bins:",
                  min = 1,
                  max = 100,
                  value = 60),
      
      # Set basemean, logcpm or aveexpr threshold
      uiOutput("setThresh")
    
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot"),
      htmlOutput("srpText")
    )
  )
))
