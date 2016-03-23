




#####################
#
#	DEVELOPPEMENT D'UNE APPLI SHINY POUR LA VISUALISATION DES QTLS MOSAIQUES ET FUSA
#
####################



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
shinyUI(navbarPage(
	
	# Choose a theme !
	theme = shinytheme("Journal"),

	# Title of the app
	"Gen Map Comparator",
	


# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




	# ----------------------
	# SHEET 1 : COMPARISON OF MAPS
	# ----------------------
	
	tabPanel(
		
		#Name
		"position comp.",
		
		# Left column to choose input
		column(2, 
			# INTRO 
			#helpText("This is an application") ,
			br(""),
			br(""),
			br(""),
    
			# CHOIX DU chromosome d'étude
			wellPanel(selectInput( "chromo", "Choose chromosome !", choices = c("all","1A","1B","2A","2B","3A","3B","4A","4B","5A","5B","6A","6B","7A","7B"), selected =c("1A") )),
			br(),
			br(),
			
			# Choix de la map
			wellPanel(uiOutput("choose_maps"))

			#Close column
			),
		
		# On the space left, I draw the graph
		column(9, 
       		
       		br(""),
			plotlyOutput("plot1" ,  height = "700px")
			
			#Close column
			)

		
		#Close the tabPanel
		),




# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




	# ----------------------
	# SHEET 2 : SUMMARY STATISTICS
	# ----------------------
	tabPanel(
		
		#Name
		"Summary Statistics",
		
		# Left column to choose input
		column(2, 
			
			# Make som space
			br(""),
			br(""),
			br(""),
    
			# Choix de la map
			wellPanel(uiOutput("choose_maps2"))

			#Close column
			),
		
		# On the space left, I add the table
		column(8, offset=1,
       		
       		br(""),
			dataTableOutput('my_table_1',width="800px")
			
			#Close column
			)

		
		#Close the tabPanel
		),
		
		
		
	
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	
	
	# ----------------------
	# SHEET 3 : INTERCHROMOSOMAL ANALYSIS
	# ----------------------
	tabPanel(
		
		#Name
		"Interchromosomal Analysis",
		
		# Left column to choose input
		column(2, 
			
			# Make som space
			br(""),
			br(""),
			br(""),
			
			# CHOIX DU chromosome d'étude
			wellPanel(selectInput( "chromo_sheet3", "Choose chromosome !", choices = c("all","1A","1B","2A","2B","3A","3B","4A","4B","5A","5B","6A","6B","7A","7B"), selected =c("1A") )),
			br(),
			br(),

    
			# Choix de la map
			wellPanel(uiOutput("choose_maps3"))

			#Close column
			),
		
		# On the space left, I add the plot
		column(8, offset=1,
       		
       		br(""),
			plotlyOutput("plot2" ,  height = "600px")
			
			#Close column
			)

		
		#Close the tabPanel
		),
		



# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




	# ----------------------
	# SHEET 4 : ROUGH MAP
	# ----------------------
	tabPanel(
		
		#Name
		"Rough Map",
		
		# Left column to choose input
		column(2, 
			
			# Make som space
			br(""),
			br(""),
			br(""),
			
			# Choix de la map
			wellPanel(uiOutput("choose_maps4"))

			#Close column
			),
		
		# On the space left, I add the plot
		column(8, offset=1,
       		
       		br(""),
			dataTableOutput('my_table_2' , width="600px")
			
			#Close column
			)

		
		#Close the tabPanel
		), 
		
		


# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




		
		
	# ----------------------
	# SHEET 5: DOCUMENTATION
	# ----------------------
	tabPanel(
		
		#Name
		"Documentation",
		
		# Left column to choose input
		column(8, offset=2, 
			
              	br(""),
              	helpText("This is an application developped by.... \n If you use it in your studies, please cite blablabla"),
              	a("www.r-graph-gallery.com"),
              	br(""),	br(""),
              	#TODO: écarter les logos
              	img(src="http://www.r-graph-gallery.com/wp-content/uploads/2015/10/logo3-300x225.jpg" ,  height = my_height, width = my_width),
              	img(src="https://upload.wikimedia.org/wikipedia/fr/thumb/d/d4/INRA_logo.jpg/800px-INRA_logo.jpg" ,  height = my_height, width = my_width),
              	img(src="http://www.fiches.arvalis-infos.fr/fiche_variete/css/images/logo_arvalis.png" ,  height = my_height, width = my_width),
             	img(src="http://www.supagro.fr/capeye/wp-content/uploads/2015/02/Logo-Montpellier-SupAgro-Vert-Web.jpg" ,  height = my_height, width = my_width)           	
			
			#Close column
			)

		
		#Close the tabPanel
		)



#Close the shinyUI
))


