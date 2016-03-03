




#####################
#
#	DEVELOPPEMENT D'UNE APPLI SHINY POUR LA VISUALISATION DES QTLS MOSAIQUES ET FUSA
#
####################



# TODO : la boite a idée
# - Possibilité de retourner une carte
# - Logo
# - Comment mettre plusieurs images et un titre dans la barre du haut ?
# - 2 modes de vision : High density / Low density avec les noms des marqueurs
# - Aller les voir les formats de sortie des logiciels de carto classique : MapDisto, MapMaker, OneMap, Carthagene
# - Circular plot avec le migest R package ? ou le circlize package ?
# - Ajouter une possibilité d'ajouter des données d'annotations ? GFF?
# - Ajouter positionnement des QTLs?
# - Histogramme de densité de marqueur
# - Diagramme de Venn des marqueurs communs
# - Faire un fichier de conf avec ls couleurs (au moins)
# - outil de synténie pour simplifier le graf quand beaucoup de marqueurs sont parrallèles


# POURQUOI faire un nouveau map viewer ?
# - Permet de comparer des cartes plus denses (NGS)
# - Permet des comparaisons inter-chromosomiques.
# - Utilisation sur le WEB -> 0 installation.
# - Utilisation des outils de visualisation interactive actuels !

# BIBLIO:
# - Cmap
# - Cmap3D
# - un package matplotlib dans ce papier, mais outil non communiqué http://journal.frontiersin.org/article/10.3389/fpls.2015.00367/full#B16
# - RQTL a une fonction de comparaison, mais c'est vraiment basique.
# - MapDraw : une macro excel publiée en 2003 !

# We need some Libraries
library(shiny)
library(plotly)
library(shinythemes) 
library("DT")

#Set the size of the logo of partners
my_height=70
my_width=100
my_height2=60
my_width2=100


# Let's start the UI file --> it codes for the design of the app!
shinyUI(fluidPage(

  # Choose a theme !
  theme = shinytheme("Journal"),
  
  #En tete
  fluidRow(
	br(),
	column(1,  	img(src="http://www.r-graph-gallery.com/wp-content/uploads/2015/10/logo3-300x225.jpg" ,  height = my_height2, width = my_width2)),
    column(9, h4("The GenMap Comparator"  , style = "color:orange")),
	column(1,  	img(src="http://www.supagro.fr/capeye/wp-content/uploads/2015/02/Logo-Montpellier-SupAgro-Vert-Web.jpg" ,  height = my_height2, width = my_width2)),
	column(1,  	img(src="https://upload.wikimedia.org/wikipedia/fr/thumb/d/d4/INRA_logo.jpg/800px-INRA_logo.jpg" ,  height = my_height2, width = my_width2)),
    br(),br(),br()

	),
	
	  
  # ------------------------------    SIDEBAR PANNEL FOR OPTIONS -----------------------------------
  sidebarLayout(

	sidebarPanel(

      # INTRO 
      helpText("This is an application") ,
      br(""),
    
      # CHOIX DU chromosome d'étude
	  selectInput( "chromo", "Choose a chromosome for deep exploration?", choices = c("all","1A","1B","2A","2B","3A","3B","4A","4B","5A","5B","6A","6B","7A","7B"), selected =c("1A") ),
	  
	  # Choix de la map
	  uiOutput("choose_maps")
	  

	  
    ),
    
    
    # ------------------------------    PANEAU PRINCIPAL -------------------------------------------
    mainPanel(
    
    	tabsetPanel(
 
			# --- Sheet 1 to make a deep inspection of 1 chromosome
 			tabPanel("All chromo",
              	# Graphique avec tous les chromosomes:
              	br(""),
				plotlyOutput("plot1" ,  height = "700px")
      	        ),

			# --- Sheet 2 : summary statistics
 			tabPanel("Summary statistics",
              	br(""),
				dataTableOutput('my_table_1',width="800px"),
              	br("")
              	),

			# --- Sheet 3 for inter-chromosomal analysis
 			tabPanel("Inter chromosomal analysis",
              	br(""),
				plotlyOutput("plot2" ,  height = "600px")
      	        ),

			# --- Sheet 4 : vizualize your rough map
 			tabPanel("Rough Map",
              	br(""),
				dataTableOutput('my_table_2' , width="600px")
				),

			# --- Sheet 5 for documentation
 			tabPanel("Documentation",
              	br(""),
              	helpText("This is an application developped by.... \n If you use it in your studies, please cite blablabla"),
              	a("www.r-graph-gallery.com"),
              	br(""),	br(""),
              	#TODO: écarter les logos
              	img(src="http://www.r-graph-gallery.com/wp-content/uploads/2015/10/logo3-300x225.jpg" ,  height = my_height, width = my_width),
              	img(src="https://upload.wikimedia.org/wikipedia/fr/thumb/d/d4/INRA_logo.jpg/800px-INRA_logo.jpg" ,  height = my_height, width = my_width),
              	img(src="http://www.fiches.arvalis-infos.fr/fiche_variete/css/images/logo_arvalis.png" ,  height = my_height, width = my_width),
             	img(src="http://www.supagro.fr/capeye/wp-content/uploads/2015/02/Logo-Montpellier-SupAgro-Vert-Web.jpg" ,  height = my_height, width = my_width)           	
				#plotlyOutput("plot1" ,  height = "1000px")
      	        )
      	    
      	    #close the tabsetPanel
      	    )
        #Close the mainPanel
        )
  
  #Close the sidebar layout
  )
  
#Close the shiny fluidPage
))






  
  
  
  