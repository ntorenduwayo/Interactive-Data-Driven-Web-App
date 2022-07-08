#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
#install.packages("d3heatmap_0.6.1.2.tar.gz",repos=NULL,type="source")
library(shiny)
library(shinythemes)
library(data.table)
library(readr)
library(recipes)
library(modeldata)
library(plotly)
library(moderndive)
library(tidyverse)
#library(d3heatmap)
#########################################
# Read data                             #
#########################################
df <- read_csv("Women_Prestige_Data.csv")

#########################################
# Building the model                    #
#########################################


# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$distPlot <- renderPlot({

        # generate bins based on input$bins from ui.R
        x    <- df[, c(2,3,4)]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        df %>%
          keep(is.numeric) %>% subset(select=-c(census))%>%
          gather() %>% 
          ggplot(aes(value)) +
          facet_wrap(~ key, scales = "free") +
          geom_histogram(aes(y = ..density..), 
                         bins = input$bins, fill = "grey") +
          geom_density(aes(y=..density..),color = "blue", alpha = 0.05) 
        })
    output$summ <- renderPrint({
      summary(df)
    })
    df1 <- subset(df, select=-c(census, occupation_name, type))
    correlation <- round(cor(df1), 3)
    nms <- names(df1)
    output$Heatmap <- renderPlotly({
      
      plot_ly(x = nms, y = nms, z = correlation, 
              key = correlation, type = "heatmap", source = "heatplot") %>%
        layout(xaxis = list(title = ""), 
               yaxis = list(title = ""))
    })
    output$df <- renderTable({
      df
    })
    
    # Regression output
    recipe_formula <- reactive(df  %>%
                                 recipe() %>%
                                 update_role(!!!input$dependent,new_role = "outcome") %>%
                                 update_role(!!!input$indep,new_role = "predictor") %>%
                                 prep() %>% 
                                 formula())
    
    lm_reg <- reactive(
      lm(recipe_formula(),data = df)
    )
    output$summary <- renderPrint({summary(lm_reg())
      
     })
   
    # 3 D Plot:
    # Center all predictors on their means
    
    output$viz <- renderPlotly({
      x_values <- df[,input$indep1]
      y_values <- df[,input$dependent1]
      z_values <- df[,input$indep2]
      
      # Define regression plane -------------------------------------------------
      # Construct x and y grid elements
      x_grid <- seq(from = min(x_values), to = max(x_values), length = 50)
      y_grid <- seq(from = min(y_values), to = max(y_values), length = 50)
      
      # Construct z grid by computing
      # 1) fitted beta coefficients
      # 2) fitted values of outer product of x_grid and y_grid
      # 3) extracting z_grid (matrix needs to be of specific dimensions)
      beta_hat <- df %>%
        lm(prestige ~ education + income, data = .) %>%
        coef()
      
      # model <- reactive({
      #   indep <- as.matrix(df[, input$indep])
      #   dependent <- as.matrix(df[, input$dependent])
      #   lm(dependent ~ indep, data = df) %>% coef()
      #   
      # })
      # beta_hat <- model()
      fitted_values <- crossing(y_grid, x_grid) %>%
        mutate(z_grid = beta_hat[1] + beta_hat[2]*x_grid + beta_hat[3]*y_grid)
      
      z_grid <- fitted_values %>% 
        pull(z_grid) %>%
        matrix(nrow = length(x_grid)) %>%
        t()
      
      # Define text element for each point in plane
      text_grid <- fitted_values %>% 
        pull(z_grid) %>%
        as.character() %>% 
        paste("prestige: ", ., sep = "") %>% 
        matrix(nrow = length(x_grid)) %>%
        t()
      
      # Plot using plotly -------------------------------------------------------
      plot_ly(df, x = ~education, y = ~prestige, z = ~income, width = 900, height = 600) %>%
        # 3D scatterplot:
        add_markers(
          x = x_values,
          y = y_values,
          z = z_values,
          marker = list(size = 5),
          hoverinfo = 'text',
          color = ~prestige,
          text = ~paste(
            "prestige: ", z_values, "<br>",
            "income: ", y_values, "<br>",
            "education: ", x_values 
          )
        ) %>%
        # Regression plane:
        add_surface(
          x = x_grid,
          y = y_grid,
          z = z_grid,
          hoverinfo = 'text',
          text = text_grid
        ) %>%
        # Axes labels and title:
        layout(
          title = "3D scatterplot and regression plane",
          scene = list(
            zaxis = list(title = "y: prestige"),
            yaxis = list(title = "x2: income"),
            xaxis = list(title = "x1: education")
          )
        )
    })
    # # Regression output
    #   #df %>% 
    #      # update_role(!!!input$dependent,new_role = "outcome") %>%
    #      # update_role(!!!input$indep,new_role = "predictor")) %>%
    #     model <- reactive({lm((paste(input$dependent, "~", paste(input$indep, collapse = "+"))), data = df)
    #     #summary(lmModel())
    #   #return(model)
    # # recipe_formula <- reactive(df %>%
    # #                              recipe() %>%
    # #                              update_role(!!!input$dependent,new_role = "outcome") %>%
    # #                              update_role(!!!input$indep,new_role = "predictor") %>% 
    # #                              formula())
    # # 
    # # lm_reg <- reactive(
    # #   lm(recipe_formula(),data = df)
    # # )
    # # 
    # # output$RegOut = renderPrint({summary(lm_reg())
    # 
    #   })
    # output$RegOut <- renderPrint({
    #   summary(model)
    # })
    # Histogram output var 1
    # output$distribution1 <- renderPlot({
    #   x1 <- df[, c(2,3,5)]
    #   bins <- seq(min(x1), max(x1), length.out = input$bins + 1)
    #   histDenNorm <- function (x, main = "") {
    #     hist(x, prob = TRUE, breaks = bins, main = main) # Histogram
    #     lines(density(x), col = "blue", lwd = 2) # Density 
    #     x2 <- seq(min(x), max(x), length = 40)
    #     f <- dnorm(x2, mean(x), sd(x))
    #     lines(x2, f, col = "red", lwd = 2) # Normal
    #     legend("topright", c("Density", "Normal"), box.lty = 3,
    #            lty = 3, col = c("blue", "red"), lwd = c(1, 2, 2))
    #   }
    #   x <- df$education
    #   y <- df$income
    #   z <- df$women
    #   v <- df$prestige
    #   par(mfrow= c(2,2))
    #   #histDenNorm(x, main = "education")
    #   #histDenNorm(y, main = "income")
    #   #histDenNorm(z, main = "women")
    #   histDenNorm(v, main = "prestige")
    # }, height=500, width=800)
    
    # Histogram output var 2
    output$distribution2 <- renderPlot({
      plot_income <- ggplot(data = df, aes(x = prestige, y = income)) + geom_point() + geom_smooth(method='lm')
      plot_education <- ggplot(data = df, aes(x = prestige, y = education)) + geom_point() + geom_smooth(method='lm')
      plot_women <- ggplot(data = df, aes(x = prestige, y = women)) + geom_point() + geom_smooth(method='lm')
      #plot_census <- ggplot(data = df, aes(x = prestige, y = census, col = type)) + geom_point() + geom_smooth(method='lm')
      plot_grid(plot_income, plot_education, plot_women, labels = "AUTO")
    }, height=500, width=800)
    })
