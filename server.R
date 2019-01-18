
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(ggplot2)
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
      return(NULL)
    } else {
    
    var <- colnames(Dataset())[Expcol()]
    sliderInput("thres", paste("To remove uninformative genes with low expression, set filter threshold for", var, "(slider shows 0.1% values from the lower tail):"),
                min = 0, 
                max = floor(0.001 * max(Dataset()[, Expcol()], na.rm = TRUE)), 
                value = 0)
      }
    
  })
  
  Pvalues <- reactive({
    if (is.null(Dataset())) return(NULL)
    pval_regexp <- "p[:punct:]*[:space:]*[:punct:]*[:space:]*val"
    pvcol <- grep(pval_regexp, tolower(colnames(Dataset())))
    overthresh <- Dataset()[,Expcol()] > input$thres
    Dataset()[overthresh, pvcol]
  })

  Srp <- reactive({
    
    if (is.null(Pvalues())) return(NULL)
    
    try(srp(Pvalues()))
  })
  
  output$distPlot <- renderPlot({
    
    if (is.null(Pvalues())) return(NULL)
    
    data <- data.frame(values = Pvalues())
    ggplot(data = data) +
      geom_histogram(mapping = aes(x = values), bins = input$bins) +
      labs(title = "P value histogram", 
           x = "P values",
           y = "Count")

  })
  
    output$srpText <- renderText({
      
      if (is.null(Srp())) return(NULL)
      
      if(inherits(Srp(),"try-error")) return(Srp()[1])
      
      paste0("<hr> Estimated power, based on P value histogram: <span style='color:blue'>", round(Srp()[1], 2),"</span>", 
             "<br> Proportion of true null hypotheses, &#x3C0;0: <span style='color:blue'>", round(Srp()[2], 2),"</span>", 
             "<br> Estimated number of false positives: ", round(Srp()[3], 0),
             "<br> Effects in replication study: ", round(Srp()[4], 0),
             "<br> Undetected effects: ", round(Srp()[5], 0),
             "<hr> Cannot make sense of your P value histogram? Please have a look at this blog for help: <a href='http://varianceexplained.org/statistics/interpreting-pvalue-histogram/'>How to interpret a p-value histogram</a>.")
    })

})
