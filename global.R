# ---------------------------------------------------------------------------- #
# iconos:
# https://fontawesome.com/icons?from=io
# 
# ---------------------------------------------------------------------------- #
# Paquetes:
# ---------------------------------------------------------------------------- #
# tidyverse
if(!require(tidyverse, quietly = TRUE, warn.conflicts = FALSE) ){
  install.packages('tidyverse',
                   dependencies = TRUE, 
                   repos = "http://cran.us.r-project.org")
}

# shiny
if(!require(shiny, quietly = TRUE, warn.conflicts = FALSE) ){
  install.packages('shiny',
                   dependencies = TRUE, 
                   repos = "http://cran.us.r-project.org")
}

# shinydashoard
if(!require(shinydashboard, quietly = TRUE, warn.conflicts = FALSE) ){
  install.packages('shinydashboard',
                   dependencies = TRUE, 
                   repos = "http://cran.us.r-project.org")
}

library(tidyverse)
library(shiny)
library(shinydashboard)
library(DT)

library(shinyHeatmaply)
library(plotly)
library(tidygraph)

library(visNetwork)
library(reshape2)
library(rlist)

source('scripts/load_data.R')
source('scripts/geo_api.R')
# ---------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------- #
# Obtengo datos
# Valido si los .csv existen en el directorio local, sino existen los decscargo:
# ---------------------------------------------------------------------------- #
  
  df_opciones <- data_frame()
  genes <- data_frame()
  df_cubetas <- data_frame()
  cubeta_dist_m <- data_frame()
  cubeta_rs <- data_frame()
  
# ---------------------------------------------------------------------------- #


# ---------------------------------------------------------------------------- #
# Declaro variables globales:
# ---------------------------------------------------------------------------- #
total_genes <- 0
total_grupos <- 0
genes_grupo <- 0

max_dist <- 1

lst_gen <- c(" ", "Gene", " - otras opciones - ")
lst_expresiones <- c()
lst_cubetas <- c()

# ---------------------------------------------------------------------------- #
