
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("P value histogram-based retrospective power"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    
    sidebarPanel(
      # Select file
      fileInput(inputId = "file1",
                label = "Choose .csv file with your many P values"),
      # Select number of bins
      sliderInput("bins",
                  "Number of bins:",
                  min = 1,
                  max = 100,
                  value = 60)
      ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot")
    )
  )
))
