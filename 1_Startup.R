#Startup-Script 

# set working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

#Install required Packages:
source('install_packages.R')

# These two might require your attention during installation:
install.packages('keras')
install.packages('kerasR')

