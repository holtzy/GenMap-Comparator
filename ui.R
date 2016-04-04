




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
	theme = shinytheme("United"),
	
	# And I custom it with additionnal CSS
	includeCSS("www/genComp.css") ,

	# Title of the app
	("The Gen Map Comparator") ,
	
	#Fabrication d'un style spécifique à la page de garde.
	#tags$head(
   # 	tags$style(HTML(".homepage {
	#			background-image: url( http://papillondamour.p.a.pic.centerblog.net/fb850229.jpg );
	#			background-color : yellow;
	#			background-attachment:fixed;
	#			background-repeat:repeat;
    #	}"))),
  		
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	# ----------------------
	# SHEET 0 : HOME PAGE
	# ----------------------
	
	tabPanel( 

		#Name
		h4("Home") ,#class = "homepage",
		br(""),br(""),br(""),

		
		#img(src = "test.png", height = 472, width = 472),

			
		# Left column to choose input
		column(12, offset=0, align="center" ,
			style="
				background-image: url( test.png);
				background-color: red;
				margin-top: -20px;
				width: 100%;
				",

			#class = "first_page",
			# INTRO 
			br(""),br(""),br(""),
			helpText(strong("The Genetic Map Comparator" , style="color:white ; font-family: 'times'; font-size:30pt ; font-type:bold" ) ) ,
			br(""),
			helpText(strong(p("Welcome to a world of genetic map. If you need to compare and characterize maps, " , style="color:white ; font-family: 'times'; font-size:20pt"))) ,
			helpText(strong(p("you are in the good place !" , style="color:white ; font-family: 'times'; font-size:20pt"))) ,
			br(""),
			br(""),
			helpText(h3("Please select your data : ")) ,
			fileInput("inputId", label=NULL , multiple = TRUE, accept = NULL, width = '200px')
					
			#Close column
			)

		#Close the tabPanel
		),

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------











# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	# ----------------------
	# SHEET 1 : SUMMARY STATISTICS
	# ----------------------
	tabPanel(
		
		#Name
		h4("Summary Statistics"),
		
		# First Row : bar and pieplot whit corresponding widget
		fluidRow(
		
			#Left column to choose input
			column(2, 
				
				# chooser map
				br(),br(),br(),
				wellPanel(uiOutput("choose_maps_sheet2")),
	
				# choose variable for barplot
				br(),
				wellPanel(radioButtons( "var_for_barplot", "Show on barplot:", choices = c("nb. marker","size","average gap","biggest gap","Nb. uniq pos."), selected =c("nb. marker") , inline = TRUE ))
				
				#Close column
				),

			#Center column for PiePlot
			column(3,  plotOutput("my_pieplot", height = "500px" ,  width = "500px" ) ),

			#Right column for Barplot
			column(7 , plotOutput("my_barplot" , height = "500px" ,  width = "900px")   )
			
		#Close first fluidRow
		),
		
		# Second fluid row for the circular plot !
		br(""),
		fluidRow(
		
			column(2, 
		
				# Choose chromosome
				wellPanel(checkboxGroupInput( "chromo_sheet2", "Choose chromosome !", choices = c("all","1A","1B","2A","2B","3A","3B","4A","4B","5A","5B","6A","6B","7A","7B"), selected =c("1A","1B") , inline = TRUE ))

				#Close column
				),

			column(8, offset=2,
				plotOutput("circular_plot" ,  height = "700px" ,  width = "700px" )

			#Close column
			)

		#Close Second fluidRow
		)
		
		#Close the tabPanel
		),
		
		
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	



# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	# ----------------------
	# SHEET 2 : COMPARISON OF MAPS
	# ----------------------
	
	tabPanel( class = "two",
	
		#Name
		h4("Compare positions") ,
		
		# Left column to choose input
		column(2, 

			# CHOIX DU chromosome d'étude
			br(""),	br(""),	br(""),
			wellPanel(selectInput( "chromo", "Choose chromosome !", choices = c("all","1A","1B","2A","2B","3A","3B","4A","4B","5A","5B","6A","6B","7A","7B"), selected =c("1A") )),
			br(),br(),
			
			# Choix de la map
			wellPanel(uiOutput("choose_maps"))

			#Close column
			),
		
		# On the space left, I draw the graph
		column(9, 
       		
       		br(""),
			plotlyOutput("plot1" ,  height = "600px")
			
			#Close column
			)
		
		#Close the tabPanel
		),

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	# ----------------------
	# SHEET 3 : INTERCHROMOSOMAL ANALYSIS
	# ----------------------
	tabPanel(
		
		#Name
		h4("Interchromosomal Analysis"),
		
		# Left column to choose input
		column(2, 
			
			# Make som space
			br(""), br(""),
			
			# Choose the chromosome
			wellPanel(selectInput( "chromo_sheet3", "Choose chromosome !", choices = c("all","1A","1B","2A","2B","3A","3B","4A","4B","5A","5B","6A","6B","7A","7B"), selected =c("all") )),
			br(),
    
			# Choix de la map1
			wellPanel(uiOutput("map1")),

			# Choix de la map2
			wellPanel(uiOutput("map2"))

			#Close column
			),
		
		# On the space left, I add the plot
		column(8, 
       		
			plotlyOutput("plot2" ,  height = "700px" ,  width = "1100px")
			
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
		h4("Rough Map"),
		
		# Left column to choose input
		column(2, 
			
			# Make som space
			br(""),	br(""),	br(""),
			
			# Choix de la map
			wellPanel(uiOutput("choose_maps4")),
			
			# Choose chromosome
			br(""),
			wellPanel(checkboxGroupInput( "chromo_sheet4", "Choose chromosome !", choices = c("all","1A","1B","2A","2B","3A","3B","4A","4B","5A","5B","6A","6B","7A","7B"), selected =c("1A","1B") , inline = TRUE ))

			#Close column
			),
		
		# On the space left, I add the plot
		column(8, offset=2,
       		
       		br(""),
			dataTableOutput('my_rough_map_viz' , width="500px")
			
			#Close column
			)

		
		#Close the tabPanel
		), 
		
		


# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------










# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		
	# ----------------------
	# SHEET 5: DOCUMENTATION
	# ----------------------
	tabPanel(
		
		#Name
		h4("Documentation"),
		
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

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





#Close the shinyUI
))


