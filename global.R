
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
library(RColorBrewer)
library(shinyAce) 
library(shinythemes) 
library(qualV)
		
# == Colors for the App :
my_colors=brewer.pal( 12 , "Set3")[-2]

# == Get the legends
legend1=read.table("LEGEND/legend_sheet1.txt",sep="@")[,2]
legend2=read.table("LEGEND/legend_sheet2.txt",sep="@")[,2]
legend3=read.table("LEGEND/legend_sheet3.txt",sep="@")[,2]
legend4=read.table("LEGEND/legend_sheet4.txt",sep="@")[,2]
legend5=read.table("LEGEND/legend_sheet5.txt",sep="@")[,2]
legend6=read.table("LEGEND/legend_sheet6.txt",sep="@")[,2]

# == Functions
# Donut plot
source("RESSOURCES/donut_function.R")

# == Set the size of the logo of partners
grand=1.5

