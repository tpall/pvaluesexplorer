
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(SRP)
load("data/GSE79519.RData")

shinyServer(function(input, output) {
  
  ### Data import:
  Dataset <- reactive({
    
    if (is.null(input$infile)) {
      return(GSE79519)
    }
    
    data.frame(data.table::fread(input = input$infile$datapath))
  })
  
  Expcol <- reactive({
    if (is.null(Dataset())) return(NULL) 
    grep("basem|logcp|aveex", tolower(colnames(Dataset())))
  })
  
  output$setThresh <- renderUI({
    
    if (is.null(Dataset())) {
      pvalues <- NULL
    } else {
    
    var <- colnames(Dataset())[Expcol()]
    sliderInput("thres", paste("To remove uninformative genes with low expression, set filter threshold for", var, "(showing 0.1% values from the lower tail):"),
                min = 0, 
                max = floor(0.001*max(Dataset()[, Expcol()], na.rm=TRUE)), 
                value = 0)
      }
    
  })
  
  Pvalues <- reactive({
    if (is.null(Dataset())) return(NULL)
    
    pvcol <- grep("^p-?val", tolower(colnames(Dataset())))
    overthresh <- Dataset()[,Expcol()]>input$thres
    Dataset()[overthresh, pvcol]
  })

  Srp <- reactive({
    
    if (is.null(Pvalues())) return(NULL)
    
    try(srp(Pvalues()))
  })
  
  output$distPlot <- renderPlot({
    
    if (is.null(Pvalues())) return(NULL)
    
    bins <- seq(0, 1, length.out = input$bins + 1)

    # draw the histogram with the specified number of bins
    hist(Pvalues(), 
         main = "P value histogram",
         xlab = "P values", 
         breaks = bins, 
         col = 'darkgray', 
         border = 'white')

  })
  
    output$srpText <- renderText({
      
      if (is.null(Srp())) return(NULL)
      
      if(inherits(Srp(),"try-error")) return(Srp()[1])
      
      paste0("SRP: ", round(Srp()[1], 2), 
             "; pi0: ", round(Srp()[2], 2), 
             "; estimated number of false positives: ", round(Srp()[3], 0),
             "; effects in replication study: ", round(Srp()[4], 0),
             "; undetected effects: ", round(Srp()[5], 0),".")
    })

})
