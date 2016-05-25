

		################################################
		#
		#		THE GENETIC MAP COMPARATOR
		#
		###############################################


# Pour se connecter au server Shiny de AGAP:
#		ssh holtz@147.100.164.72
#		?LOF@L~$QPt=diTIhXg5u<EA3
#  Pour mettre l'appli sur le webserveur de Agap (disponible sur le web: http://147.100.164.72/) :
#		cd /Users/holtz/Dropbox
#		scp -r  GenMap-Comparator/ holtz@147.100.164.72://srv/shiny-server/holtz-apps
#  Pour accéder a l'appli en ligne
#		147.100.164.72/holtz-apps/GenMap-Comparator



# Let's start the UI file --> it codes for the design of the app!
shinyUI(navbarPage(

	# Choose a theme !
	theme = shinytheme("united"),
	
	# And I custom it with additionnal CSS
	includeCSS("www/genComp.css") ,

	# Title of the app
	("The Gen Map Comparator") ,
	
  		
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	# ----------------------
	# SHEET 1 : HOME PAGE
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
			helpText(strong(p(legend[1] , style="color:white ; font-family: 'times'; font-size:18pt"))) ,
			helpText(strong(p(legend[2] , style="color:white ; font-family: 'times'; font-size:18pt"))) ,
			br(""),
			helpText(strong(p(legend[3] , style="color:orange ; font-family: 'times'; font-size:18pt"))) ,
			
			
			#widget to choose a directory
			directoryInput('directory', label = 'select a directory with all maps', value = 'DATA/'),
			
			
			#fileInput("inputId", label=NULL , multiple = TRUE, accept = NULL, width = '200px'),
			br(""),
			p(
				"By", 
				a(em("Holtz Yan") , style="color:white ; font-family:'times'; font-size:15pt", href = "https://holtzyan.wordpress.com/" , target="_blank"),
				style="color:white ; font-family: 'times'; font-size:15pt"
				),
			p(
				legend[4], 
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
	# SHEET 2 : SUMMARY STATISTICS
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
				wellPanel(uiOutput("choose_chromo_sheet2"))

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
	# SHEET 3 : COMPARISON OF MAPS
	# ----------------------
	
	tabPanel( class = "two",
	
		#Name
		h4(legend[6]) ,
		
		# Left column to choose input
		column(2, 

			# CHOIX DU chromosome d'étude
			br(""),	br(""),	br(""),
			wellPanel(uiOutput("choose_chromo_sheet3")),
			br(),br(),
			
			# Choix de la map
			wellPanel(uiOutput("choose_maps3"))

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
	# SHEET 4 : INTERCHROMOSOMAL ANALYSIS
	# ----------------------
	tabPanel(
		
		#Name
		h4(legend[9]),
		
		# Left column to choose input
		column(2, 
			
			# Make som space
			br(""), br(""),
			
			# Choose the chromosome
			wellPanel(uiOutput("choose_chromo_sheet4")),
			br(),
    
			# Choix de la map1
			wellPanel(uiOutput("map1")),

			# Choix de la map2
			wellPanel(uiOutput("map2"))

			#Close column
			),
		
		# On the space left, I add the plot
		column(8, 
			
			br(),
			plotlyOutput("plot2" ,  height = "700px" ,  width = "900px")			
			
			#Close column
			),

		# Legend of the plot
		column(2, 
       		br(),
       		plotOutput("key_numbers_sheet_3", height = "500px" ,  width = "350px"),
       		br(),br(),
			helpText(strong(p(legend[11] , style="color:grey ; font-family: 'times'; font-size:12pt")))
			#Close column
			)

		#Close the tabPanel
		),
		



# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




	# ----------------------
	# SHEET 5 : ROUGH MAP
	# ----------------------
	tabPanel(
		
		#Name
		h4(legend[12]),
		
		# Left column to choose input
		column(2, 
			
			# Make som space
			br(""),	br(""),	br(""),
			
			# Choix de la map
			wellPanel(uiOutput("choose_maps5")),
			
			# Choose chromosome
			br(""),
			wellPanel(uiOutput("choose_chromo_sheet5"))

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
			helpText(strong(p(legend[14] , style="color:grey ; font-family: 'times'; font-size:12pt")))
			#Close column
			)


		
		#Close the tabPanel
		), 
		
		


# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------










# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		
	# ----------------------
	# SHEET 6: DOCUMENTATION
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
              	helpText(legend[15],br(""),legend[16],br(""),legend[17],br(""),legend[18],br(""),legend[19],br(""),legend[20],br(""),legend[21],  style="color:black ; font-family: 'times'; font-size:17pt ; font-type:bold" ), 
              	br(""),	br(""),br("")

  			#Close column
			),
            	
              	
 		column(3, offset=0, 
 				br(""),br(""),
              	helpText(legend[22], style="color:grey ; font-family: 'times'; font-size:15pt ; font-type:bold" ),    	      
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


