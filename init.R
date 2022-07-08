# init.R
#
# Example R code to install packages if not already installed
#

my_packages = c("modeldata", "plotly", "shinydashboard", "shinyWidgets",
                "maps", "dplyr", "leaflet", "shinycssloaders", "shinythemes",
                "rio", "DT", "stargazer", "readr", "purrr", "tidyr", "ggplot2",
                "psych", "cowplot", "AICcmodavg", "tidyverse", "moderndive",
                "plot3D", "misc3d", "recipes", "shinythemes", "data.table")

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p, clean=TRUE, quiet=TRUE)
  }
}

invisible(sapply(my_packages, install_if_missing))