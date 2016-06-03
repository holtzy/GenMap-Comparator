

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
#		http://www.agap-sunshine.inra.fr/holtz-apps/GenMap-Comparator/
#  Pour lancer l'appli
#		cd /Users/holtz/Dropbox ; R ; library(shiny) ; runApp("GenMap-Comparator")


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
			
			# Test of widget to choose several files:
			fileInput("file1", strong(p(legend[3] , style="color:orange ; font-family: 'times'; font-size:18pt")) , multiple = TRUE, accept=NULL),
			
			# widget to propose 2 exemples
			helpText(strong(p("Or an example dataset:" , style="color:orange ; font-family: 'times'; font-size:18pt"))) ,
			actionButton("button_for_ex1", "Wheat"),
			actionButton("button_for_ex2", "Sorghum"),
			
			br(""),br(""),br(""),
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
		
		# ==== Title in Orange
		fluidRow(align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				helpText( strong(" - Summary Statistics - " , style="color:Orange ; font-family: 'times'; font-size:30pt ; font-type:bold" )) ,
				hr()
		)),


		# === Some text to explain the Figure:
		fluidRow(
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),"Ergo ego senator inimicus, si ita vultis, homini, amicus esse, sicut semper fui, rei publicae debeo. Quid? si ipsas inimicitias, depono rei publicae causa, quis me tandem iure reprehendet, praesertim cum ego omnium meorum consiliorum atque factorum exempla semper ex summorum hominum consiliis atque factis mihi censuerim petenda.",br()
				)
			),br(),br(),

		# === Two widgets to select maps and variables for pie and barplot:
		fluidRow(
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(3,offset=3,
				wellPanel(uiOutput("choose_maps_sheet2"))
				),
			column(3,offset=0,
				wellPanel(radioButtons( "var_for_barplot", "Show on barplot:", choices = c("nb. marker","size","average gap","biggest gap","Nb. uniq pos."), selected =c("nb. marker") , inline = TRUE ))
				)
			),
		
		
		# === Bar and pieplot whit corresponding widget
		fluidRow(
		
			# PiePlot
			column(3, offset=1,  plotOutput("my_pieplot", height = "500px" ,  width = "500px" ) ),

			#Barplot
			column(7 , plotOutput("my_barplot" , height = "500px" ,  width = "1000px")   )

		),br(),
		
		# === Separation
		#fluidRow( column( 6,offset=3, hr())),
		

		# ==== Title 2 in Orange
		fluidRow(align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				helpText( strong(" - Markers density - " , style="color:Orange ; font-family: 'times'; font-size:30pt ; font-type:bold" )) ,
				hr()
		)),


		# === Some text to explain the Figure:
		fluidRow(
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),"Ergo ego senator inimicus, si ita vultis, homini, amicus esse, sicut semper fui, rei publicae debeo. Quid? si ipsas inimicitias, depono rei publicae causa, quis me tandem iure reprehendet, praesertim cum ego omnium meorum consiliorum atque factorum exempla semper ex summorum hominum consiliis atque factis mihi censuerim petenda.",br()
				)
			),br(),br(),

		# === One widget to select maps and variables for pie and barplot:
		fluidRow( align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(2,offset=5,
				wellPanel(uiOutput("choose_chromo_sheet2"))
				)
			),

		# === Fluid row for the circular plot !
		br(""),
		fluidRow(align="center",
			column(12, offset=0,
				plotOutput("circular_plot" ,  height = "700px" ,  width = "700px" )
			)
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
		
		# ==== Title in Orange
		fluidRow(align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				helpText( strong(" - Maps comparison - " , style="color:Orange ; font-family: 'times'; font-size:30pt ; font-type:bold" )) ,
				hr()
		)),


		# === Some text to explain the Figure:
		fluidRow(
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),"Ergo ego senator inimicus, si ita vultis, homini, amicus esse, sicut semper fui, rei publicae debeo. Quid? si ipsas inimicitias, depono rei publicae causa, quis me tandem iure reprehendet, praesertim cum ego omnium meorum consiliorum atque factorum exempla semper ex summorum hominum consiliis atque factis mihi censuerim petenda.",br()
				)
			),br(),br(),


		# === Two widgets to select maps and variables for pie and barplot:
		fluidRow( align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(3,offset=3,
				wellPanel(uiOutput("choose_chromo_sheet3"))
				),
			column(3,offset=0,
				wellPanel(uiOutput("choose_maps3"))
				)
			),

		# === Separation
		fluidRow( column( 6,offset=3, hr())),

			
		# === Comparison graph
		column(11, offset=1, 
       		br(""), plotlyOutput("plot1" ,  height = "800px")
			),


		# === Separation
		br(),fluidRow( column( 6,offset=3, hr())), br(), br()


		
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
		
		# ==== Title in Orange
		fluidRow(align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				helpText( strong(" - Interchromosomal Analysis - " , style="color:Orange ; font-family: 'times'; font-size:30pt ; font-type:bold" )) ,
				hr()
		)),


		# === Some text to explain the Figure:
		fluidRow(
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),legend[11],br()
				)
			),br(),br(),


		# === Left column to choose input
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
		
		# === On the space left, I add the plot
		column(8, 
			
			br(),
			plotlyOutput("plot2" ,  height = "700px" ,  width = "900px")			
			
			#Close column
			),

		# === Key numbers
		column(2, 
       		br(), plotOutput("key_numbers_sheet_3", height = "500px" ,  width = "350px"), br(),br()
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
		
			
		# ==== About section
		fluidRow(align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				helpText( strong(" - About - " , style="color:Orange ; font-family: 'times'; font-size:30pt ; font-type:bold" )) ,
				hr()
		)),
		fluidRow(
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(3,offset=3,
				br(),
				"The Genetic map comparators should permit to compare easily and quickly several genetic maps. The Genetic map comparators should permit to compare easily and quickly several genetic maps. The Genetic map comparators should permit to compare easily and quickly several genetic maps",
				br()
				),
			column(3,offset=0,
				br(),
				"The Genetic map comparators should permit to compare easily and quickly several genetic maps. The Genetic map comparators should permit to compare easily and quickly several genetic maps. The Genetic map comparators should permit to compare easily and quickly several genetic maps",
				br()
		)), br(),br(),





		# ==== Input files description
		fluidRow(align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				helpText( strong(" - Input Files - " , style="color:Orange ; font-family: 'times'; font-size:30pt ; font-type:bold" )) ,
				hr()
		)),
		fluidRow(align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				"The application imports linkage data from map files, produced by software for linkage analysis. Two formats are accepted:",
				br(),
				"- \"Carthagene format\", where map files are composed of 3 columns: linkage group, marker name and position in the map." ,
				br(),
				"- \"MapChart format\", where map files are composed of a sequence of linkage groups, each with a header line specifying the linkage group title, followed by a sequence of lines with locus names and map positions. Such map files are exported by JoinMap 3.0",
				br(),
				" The columns names of files does not matter. Columns must be separated by either \";\" or tabulation (\"\t\") ",
				br()
		)), br(),
		fluidRow( 
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(3,offset=3,align="center",
				br(),
				dataTableOutput('doc_ex1' , width="100px"),
				br()
				),
			column(3,offset=0,align="center",
				br(),
				dataTableOutput('doc_ex2' , width="100px"),
				br()
		)), br(),





		# ==== Contact
		fluidRow(align="center",
			style="opacity: 1;background-color:white; margin-top: 0px;width: 100%;",
			column(6,offset=3,
				# Set the style of this page
				br(),
				helpText(strong(" - Contact - " , style="color:orange ; font-family: 'times'; font-size:30pt ; font-type:bold" ) ) ,
				hr()
			)),
		fluidRow( align="center",
			style="opacity: 1;background-color:white; margin-top: 0px;width: 100%;",
			column(3,offset=3,
				img(src="https://holtzyan.files.wordpress.com/2015/07/montpellier.png" ,  height = 300, width = 500),
				br()
				),
			column(3,offset=1,
				br(),br(),
				helpText("Yan Holtz: holtz@supagro.fr"),
				helpText("Vincent Ranwez: ranwez@supagro.fr"),
				br(),br(),br(),
				"Ge2pop Team, Bâtiment 21",br(),
				"Montpellier SupAgro,",br(),
				"2 place Pierre Viala",br(),
				"34060 MONTPELLIER Cedex 1",br(),
				"FRANCE",
				br()
				)
			),
		fluidRow(column(6,offset=3,hr())) , br() ,	
		
		#Black line?
		fluidRow( style=" opacity: 0.8 ; background-color: white ; margin-top: 0px ; width: 100%; "  ),
	


		
		# === Last bandeau for the logos
		fluidRow(
			
			# Set the style of this page
			style=" opacity: 0.8 ; background-color: black ; margin-top: 0px ; width: 100%; ",
		
			# put the logos
			br(),
			column(2, offset=4, img(src="https://upload.wikimedia.org/wikipedia/fr/thumb/d/d4/INRA_logo.jpg/800px-INRA_logo.jpg" ,  height = 70*grand, width = 120*grand) , br(),br() ),
			column(2, offset=0, img(src="http://www.fiches.arvalis-infos.fr/fiche_variete/css/images/logo_arvalis.png" ,  height = 70*grand, width = 100*grand) ),
			column(2, offset=0, img(src="http://www.supagro.fr/capeye/wp-content/uploads/2015/02/Logo-Montpellier-SupAgro-Vert-Web.jpg" ,  height = 70*grand, width = 110*grand) )
			
			)

		#Close the tabPanel
		)

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





#Close the shinyUI
))


