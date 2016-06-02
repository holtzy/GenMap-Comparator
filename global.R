
		################################################
		#
		#		THE GENETIC MAP COMPARATOR
		#
		###############################################


# In this file, I add all functions / file / parameters that are NOT reactive and that are common to ui.R and server.R
# It is my global environment !

# == Libraries
library(shiny)
library(plotly)
library(DT)
library(circlize)
library(RColorBrewer)
library(shinyAce) 
library(shinythemes) 

# == Colors for the App :
my_colors=brewer.pal( 12 , "Set3")[-2]

# == Get the legends
legend=read.table("LEGEND/all_legend.txt",sep="@")[,2]

# == Functions
# Donut plot
source("RESSOURCES/donut_function.R")

# == Set the size of the logo of partners
grand=1.7

