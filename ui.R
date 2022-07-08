#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
################################################
# Loading Libraries                            #
################################################
#install.packages("d3heatmap_0.6.1.2.tar.gz",repos=NULL,type="source")
library(shiny)
#library(shinydashboard)
#library(shinyWidgets) 
library(maps)
library(dplyr)
#library(leaflet)
#library(shinycssloaders)
#library(shinythemes)
# library(datadigest)
#library(rio)
#library(DT)
#library(stargazer)
library(readr)
#library(purrr)
library(tidyr)
library(ggplot2)
#library(psych)
library(cowplot)
#library(AICcmodavg)
library(tidyverse)
library(plotly)
#library(moderndive)
#library(plot3D)
#library(misc3d)
library(recipes)
#library(modeldata)
##library(d3heatmap)
AttributeChoices=c("education","income","women","prestige")
df <- read_csv("Women_Prestige_Data.csv")
######################################################
# Define UI for application that create a regression #
######################################################

shinyUI(fluidPage(

    # Application title
    titlePanel("Build a Linear Regression Model"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(strong("Use the slide bellow to increase or decrease the number of bins for distribution plots."),
            sliderInput("bins",
                        "Number of bins:",
                        min = 0,
                        max = 30,
                        value = 15,
                        step = 5),
            navlistPanel(
              "Model summary",
            #selectInput(inputId = "dependent", label = "Dependent Variables",
                        #choices = colnames(df[,5])),
              selectInput(inputId = "dependent", label = "Dependent Variable",
                        choices = colnames(df[,5])),
            # selectInput(inputId = "indep", label = "Independent Variables", 
            #             multiple = TRUE, choices = colnames(df[,2:4]), selected = "education"),
              selectInput(inputId = "indep", label = "Independent Variables", 
                         multiple = TRUE, choices = colnames(df[,2:4]), selected = "education")
            # selectInput(inputId = "indep1", label = "1. Independent Variables", 
            #             multiple = TRUE, choices = colnames(df[,2:4]), selected = "education"),            
                        
            ),
            navlistPanel(
              "3D Model Visualization",
              selectInput(inputId = "dependent1", label = "Dependent Variable", 
                          choices = colnames(df[,5]), selected = "prestige"),
              selectInput(inputId = "indep1", label = "Independent Variable 1", 
                          multiple = TRUE, choices = colnames(df[,2]), selected = "education"),
              selectInput(inputId = "indep2", label = "Independent Variable 2", 
                          multiple = TRUE, choices = colnames(df[,3]), selected = "income")
            )),
        
          # selectInput(inputId="dependent", label = "Dependent Variables",
          #             choices = as.list(AttributeChoices)),
          # selectInput(inputId = "indep", label = "Independent Variables", 
          #             multiple = TRUE, choices = as.list(AttributeChoices), selected = AttributeChoices[1]),
          # 
        
        # Show a plot of the generated distribution
        mainPanel(
          tabsetPanel(type = "tab",
                      tabPanel("Data", tableOutput("df")),
                      tabPanel("Data Summary", verbatimTextOutput("summ")),
                      tabPanel("Distribution Plots", plotOutput("distPlot")),
                      tabPanel("Correlation Heatmap", plotlyOutput("Heatmap", width = "100%", height = "600px")),
                      tabPanel("Model Summary", verbatimTextOutput(outputId = "summary")),
                      tabPanel("Response vs Predictors Relationship Plots", # Plots of distributions
                               fluidRow(
                                 #column(8, plotOutput("distribution1")),
                                 column(9, plotOutput("distribution2")))
                      ),
                      # tabPanel("Regression",
                      #          tabname="regression",
                      #          icon=icon("calculator"),
                      #          selectInput(inputId="dependent", label = "Dependent Variables",
                      #                      choices = as.list(AttributeChoices)),
                      #          selectInput(inputId = "indep", label = "Independent Variables", 
                      #                      multiple = TRUE, choices = as.list(AttributeChoices), selected = AttributeChoices[1]),
                      #          
                      #          verbatimTextOutput(outputId = "RegOut")
                      # ),
                      tabPanel("3D Model Visualization", plotlyOutput("viz"))
                      
        )
    )
))
)
