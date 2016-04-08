




#####################
#
#	DEVELOPPEMENT D'UNE APPLI SHINY POUR LA VISUALISATION DES QTLS MOSAIQUES ET FUSA
#
####################


#  Pour se connecter au server Shiny de AGAP:
#		ssh holtz@147.100.164.72
#		?LOF@L~$QPt=diTIhXg5u<EA3
#  Pour mettre l'appli sur le webserveur de Agap (disponible sur le web: http://147.100.164.72/) :
#		cd /Users/holtz/Dropbox
#		scp -r  GenMap-Comparator/ holtz@147.100.164.72://srv/shiny-server/holtz-apps
#  Pour accéder a l'appli en ligne
#		147.100.164.72/holtz-apps/GenMap-Comparator


# We need some Libraries
library(shiny)
library(plotly)
library(shinythemes) 
library("DT")
library(shinyAce) 

#Make the background Image of the homepage
grand=60
#png("www/my_image.png" , width = 40*grand, height = 22*grand)
#par(bg="black" )
#my_colors=c(rgb(0.2,0.2,0.4,0.5), rgb(0.8,0.2,0.4,0.5), rgb(0.2,0.9,0.4,0.2) )
#library(MASS)
#par(mar=c(0,0,0,0))
#my_iris=iris[,c(1,2,3,4,1,3,2,4,5)]
#ze_colors=my_colors[as.numeric(my_iris$Species)]
#par(cex.axis=2 , col.lab="white" , col.axis="grey")
#parcoord(my_iris[,c(1:8)] , col= ze_colors , ylim=c(0.1,0.8) , xlim=c(3,7.5) )
#dev.off()



#Set the size of the logo of partners
grand=1.7


# Let's start the UI file --> it codes for the design of the app!
shinyUI(navbarPage(

	
	# Choose a theme !
	theme = shinytheme("united"),
	
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

		# Name
		h4("Home") ,

		# Only one zone for the home page
		column(12, offset=0, align="center" ,
			
			# Set the style of this page
			style="
				background-image: url(my_image.png);
				opacity: 0.8;
				background-color: black;
				margin-top: -20px;
				width: 100%;
				",

			# And write the welcome message
			br(""),br(""),br(""),
			helpText(strong("The Genetic Map Comparator" , style="color:white ; font-family: 'times'; font-size:50pt ; font-type:bold" ) ) ,
			br(""),
			helpText(strong(p("Welcome to a world of genetic map. If you need to compare and characterize maps, " , style="color:white ; font-family: 'times'; font-size:18pt"))) ,
			helpText(strong(p("you are in the right place!" , style="color:white ; font-family: 'times'; font-size:18pt"))) ,
			br(""),
			helpText(strong(p("Please select your data: " , style="color:orange ; font-family: 'times'; font-size:18pt"))) ,
			fileInput("inputId", label=NULL , multiple = TRUE, accept = NULL, width = '200px'),
			br(""),
			p(
				"By", 
				a(em("Holtz Yan") , style="color:white ; font-family:'times'; font-size:15pt", href = "https://holtzyan.wordpress.com/" , target="_blank"),
				style="color:white ; font-family: 'times'; font-size:15pt"
				),
			p(
				"With contribution of", 
				a(em("Vincent Ranwez") , style="color:white ; font-family:'times'; font-size:15pt", href = "https://sites.google.com/site/ranwez/" , target="_blank"),
				" & ",
				a(em("Jacques David") , style="color:white ; font-family:'times'; font-size:15pt", href = "https://www.researchgate.net/profile/Jacques_David4" , target="_blank"),
				style="color:white ; font-family: 'times'; font-size:15pt"
				),
			
			br(""),br(""),br(""),br(""),br(""),br(""),br(""),br(""),br(""),br("")

					
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
			column(7 , plotOutput("my_barplot" , height = "500px" ,  width = "1000px")   )
			
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
			plotlyOutput("plot1" ,  height = "800px")
			
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
       		
			plotlyOutput("plot2" ,  height = "700px" ,  width = "1000px")
			
			#Close column
			),

		# Legend of the plot
		column(2, 
       		br(),br(),br(),br(),
			helpText(strong(p("Fig. 5: This is a comparison of markers positions for 2 selected maps. Choosing 1 chromosome only, it permits to visualize evolution of recombination rates among maps. If you select all chromosomes, it permits to discover interchromosomal recombinations" , style="color:grey ; font-family: 'times'; font-size:12pt")))
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
		column(6, offset=2,
       		
       		br(""),
			dataTableOutput('my_rough_map_viz' , width="500px")
			
			#Close column
			),
			
		# Legend of the plot
		column(2, 
       		br(),br(),br(),br(),br(),br(),
			helpText(strong(p("Fig. 6: This table shows the rough data: the selected map as you gave it in input. You can order it by chromosome or position, search for a specific marker..." , style="color:grey ; font-family: 'times'; font-size:12pt")))
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
		
		# Left column for logos:
		column(2, offset=0, 
               	br(""),br(""),
            	img(src="http://www.r-graph-gallery.com/wp-content/uploads/2015/10/logo3-300x225.jpg" ,  height = 70*grand, width = 100*grand),
              	br(""),br(""),
              	img(src="https://upload.wikimedia.org/wikipedia/fr/thumb/d/d4/INRA_logo.jpg/800px-INRA_logo.jpg" ,  height = 70*grand, width = 120*grand),
              	br(""),br(""),
              	img(src="http://www.fiches.arvalis-infos.fr/fiche_variete/css/images/logo_arvalis.png" ,  height = 70*grand, width = 100*grand),
             	br(""),br(""),
             	img(src="http://www.supagro.fr/capeye/wp-content/uploads/2015/02/Logo-Montpellier-SupAgro-Vert-Web.jpg" ,  height = 70*grand, width = 110*grand),        	
				br("")
			#Close column
			),


		# Center for the text
		column(6, offset=0, 
			
              	br(""),br(""),
              	helpText("The Genmap Comparator is an application developped to compare and characterize genetic maps. It is sooo easy to use it: ", style="color:black ; font-family: 'times'; font-size:20pt ; font-type:bold" ), 
              	br(""),
              	helpText("1 -- Somewhere in your computer, create a directory and add all the maps you want to compare.", style="color:black ; font-family: 'times'; font-size:20pt ; font-type:bold" ) ,
              	br(""),
              	helpText("2 -- Your maps must be in the basic format, commonly used in all map softwares. Basically, it should look like that:", style="color:black ; font-family: 'times'; font-size:20pt ; font-type:bold" ) ,
              	br(""),
              	helpText("File demo", style="color:black ; font-family: 'times'; font-size:20pt ; font-type:bold" ) ,
              	br(""),
              	helpText("3 -- Go to the home page of this app, add select your folder. Now you just have to naviguate from one page to another !", style="color:black ; font-family: 'times'; font-size:20pt ; font-type:bold" ) ,
              	br(""),
              	helpText("If you use this app in your studies, please cite this reference, it helps to spread the tool !", style="color:black ; font-family: 'times'; font-size:20pt ; font-type:bold" ) ,
              	br(""),	br(""),br("")
  			#Close column
			),
            	
              	
 		column(3, offset=0, 
 				br(""),br(""),
              	helpText("Drop us a line !", style="color:grey ; font-family: 'times'; font-size:15pt ; font-type:bold" ),    	      
             	wellPanel(
       				textInput("from", "From:", value="e.g. from@gmail.com"),
          			#textInput("to", "To:", value="to@gmail.com"),
           			textInput("subject", "Subject:", value=""),
           			h5("Write message here"),
           			aceEditor("message", value=""),
           			actionButton("send", "Send mail")
          			)		
			#Close column
			)

		
		#Close the tabPanel
		)

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





#Close the shinyUI
))


