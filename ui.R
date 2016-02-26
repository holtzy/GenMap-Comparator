#####################
#
#	DEVELOPPEMENT D'UNE APPLI SHINY POUR LA VISUALISATION DES QTLS MOSAIQUES ET FUSA
#
####################





# We need some Libraries
library(shiny)
library(plotly)
library(shinythemes) 



# Let's start the UI file!
shinyUI(fluidPage(
  
  # Application title
  titlePanel(paste("\t\t\t\t\t\t","An application to compare genetic maps","\n")),
  
  # ------------------------------    SIDEBAR PANNEL FOR OPTIONS -----------------------------------
  sidebarLayout(

	sidebarPanel(

      # INTRO 
      helpText("This is an application") ,
      br(""),
    
      # CHOIX DU chromosome d'étude
	  selectInput( "chromo", "Choose a chromosome for deep exploration?", choices = c("1A","1B","2A","2B","3A","3B","4A","4B","5A","5B","6A","6B","7A","7B"), selected =c("1A") )
	  
    ),
    
    
    # ------------------------------    PANEAU PRINCIPAL -------------------------------------------
    mainPanel(
    
    	tabsetPanel(
 
			# --- Onglet 1 avec tous les chromosomes
 			tabPanel("All chromo",
              	# Graphique avec tous les chromosomes:
              	br(""),
				plotlyOutput("plot1" ,  height = "1000px")
      	        )
      	    
      	    #close the tabsetPanel
      	    )
        #Close the mainPanel
        )
  
  #Close the sidebar layout
  )
  
#Close the shiny fluidPage
))