# run.R
library(shiny)

port <- Sys.getenv('PORT')

shiny::runApp(
  appDir = getwd(),
  host = '127.0.0.1:4140',
  port = as.numeric(port)
)