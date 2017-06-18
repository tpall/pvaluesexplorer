
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyServer(function(input, output) {
  
  output$distPlot <- renderPlot({

    # generate bins based on input$bins from ui.R
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    dt <- data.table::fread(input = inFile$datapath)
    x <- data.frame(dt)[,grepl("^p-?val", tolower(colnames(dt)))]
    pvalues <- x[!is.na(x)]
    bins <- seq(min(pvalues), max(pvalues), length.out = input$bins + 1)

    # draw the histogram with the specified number of bins
    hist(pvalues, 
         main = "P value histogram",
         xlab = "P values", 
         breaks = bins, 
         col = 'darkgray', 
         border = 'white')

  })

})
