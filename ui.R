

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
#  Faire un touch restart si l'appli ne s'actualise pas bien sur le serveur.


# Let's start the UI file --> it codes for the design of the app!
shinyUI(navbarPage(

	# Choose a theme !
	theme = shinytheme("united"),
	
	# And I custom it with additionnal CSS
	includeCSS("www/genComp.css") ,

	# Title of the app (appears nowhere)
	("The Gen Map Comparator") ,
	
  		
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	# ----------------------
	# SHEET 1 : HOME PAGE
	# ----------------------
	
	tabPanel( 

		# Name
		h4(legend1[1]) ,

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
			helpText(strong(legend1[2] , style="color:white ; font-family: 'times'; font-size:50pt ; font-type:bold" ) ) ,
			br(""),
			helpText(strong(p(legend1[3] , style="color:white ; font-family: 'times'; font-size:18pt"))) ,
			br(""),
			
			# widget to choose several files:
			fileInput("file1", strong(p(legend1[4] , style="color:orange ; font-family: 'times'; font-size:18pt")) , multiple = TRUE, accept=NULL),
			uiOutput("error_message"),
				
			# widget to propose 3 exemples
			radioButtons("file2", strong(p(legend1[5] , style="color:orange ; font-family: 'times'; font-size:18pt")), choices = c("sorghum (Mace et al. 2009)","wheat (Maccaferri et al. 2015)", "wheat (Holtz et al. 2016)"), selected =c("sorghum (Mace et al. 2009)") , inline = FALSE ),
			br(),
			helpText(strong(p(legend1[6] , style="color:orange ; font-family: 'times'; font-size:18pt"))) ,
			legend1[7],	
			
			# Last part with our names. Not in the legend file..
			br(""),br(""),br(""),
			p(
				legend1[8], 
				a(em("Yan Holtz") , style="color:white ; font-family:'times'; font-size:15pt", href = "https://holtzyan.wordpress.com/" , target="_blank"),
				style="color:white ; font-family: 'times'; font-size:15pt"
				),
			p(
				legend1[9], 
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
		h4(legend2[1]),
		
		# ==== Title 2 in Orange 
		fluidRow(align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				helpText( strong(legend2[5] , style="color:Orange ; font-family: 'times'; font-size:30pt ; font-type:bold" )) ,
				hr()
		)),

		# === Some text to explain the Figure:
		fluidRow(align="justify",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),legend2[6],br()
				)
			),br(),br(),

		# === One widget to select maps and variables for pie and barplot:
		fluidRow( align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				wellPanel(uiOutput("choose_maps_sheet2_bis"))
				)
			),

		# === Fluid row for the summary table
		br(""),
		fluidRow(align="center",
			column(12, offset=0,
				dataTableOutput('sum_table' , width="700px")
			)
		),br(),br(),


		# ==== Title in Orange
		fluidRow(align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				helpText( strong(legend2[2] , style="color:Orange ; font-family: 'times'; font-size:30pt ; font-type:bold" )) ,
				hr()
		)),


		# === Some text to explain the Figure:
		fluidRow(align="justify",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),legend2[3],br(),br(),legend2[4],br(),br(),legend2[12]
				)
			),br(),br(),

		# === Two widgets to select maps and variables for pie and barplot:
		fluidRow(
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(3,offset=3,
				wellPanel(uiOutput("choose_maps_sheet2"))
				),
			column(3,offset=0,
				#wellPanel(radioButtons( "var_for_barplot", legend2[41], choices = c("nb. marker","size","average gap","biggest gap","Nb. uniq pos."), selected =c("nb. marker") , inline = FALSE ))
				wellPanel(radioButtons( "var_for_barplot", legend2[13], choices = c("# markers","map size","average gap size","biggest gap size","# unique positions"), selected =c("# markers") , inline = FALSE ))
				
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
		






		
		
		# ==== Title 3 in Orange
		fluidRow(align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				helpText( strong(legend2[7] , style="color:Orange ; font-family: 'times'; font-size:30pt ; font-type:bold" )) ,
				hr()
		)),


		# === Some text to explain the Figure:
		fluidRow(align="justify",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),legend2[8],br()
				)
			),br(),br(),

		# === One widget to select maps and variables for pie and barplot:
		fluidRow( align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				wellPanel(uiOutput("choose_chromo_sheet2"))
				)
			),

		# === Fluid row for the density plot !
		br(""),
		fluidRow(align="center",
			column(12, offset=0,
				plotOutput("circular_plot" ,  height = "1200px" ,  width = "900px" )
			)
		),br(),br()


		





		
		#Close the tabPanel
		),
		
		
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	





# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	# ----------------------
	# SHEET 3 : COMPARISON OF MAPS
	# ----------------------
	
	tabPanel( class = "two",
	
		#Name
		h4(legend3[1]) ,
		
		# ==== Title in Orange
		fluidRow(align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				helpText( strong(legend3[2] , style="color:Orange ; font-family: 'times'; font-size:30pt ; font-type:bold" )) ,
				hr()
		)),


		# === Some text to explain the Figure:
		fluidRow(align="justify",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),legend3[3],br(),br(),legend3[6],br(),br(),legend3[7],a(em("colour.") , style="color:blue", href = "http://www.color-hex.com/" , target="_blank")
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


		# === Two widgets to select maps and variables for pie and barplot:
		fluidRow( align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(3,offset=3,
				wellPanel( sliderInput("thickness", "Line thickness:", min=0.1, max=12, value=2.0) )
				),
			column(3,offset=0,
				wellPanel( textInput("my_color", "Line colour:" ,  value="purple" ) )
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
		h4(legend4[1]),
		
		# ==== Title in Orange
		fluidRow(align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				helpText( strong(legend4[2] , style="color:Orange ; font-family: 'times'; font-size:30pt ; font-type:bold" )) ,
				hr()
		)),


		# === Some text to explain the Figure:
		fluidRow(align="justify",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),legend4[3],br()
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
			wellPanel(uiOutput("map2")),
			br(),br(),br(),br(),br()

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
		h4(legend5[1]),

		# ==== Title in Orange
		fluidRow(align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				helpText( strong(legend5[6] , style="color:Orange ; font-family: 'times'; font-size:30pt ; font-type:bold" )) ,
				hr()
		)),

		# === Some text to explain the Figure:
		fluidRow(align="justify",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),legend5[2],br(),br(),legend5[5]
				)
			),br(),br(),


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
			),br(),br(),br(),
			
		# Legend of the plot
		column(2, 
       		br(),br(),br(),br(),br(),br()
			#,helpText(strong(p(legend5[2] , style="color:grey ; font-family: 'times'; font-size:12pt"))),br(),br(),
			#helpText(strong(p(legend5[5] , style="color:grey ; font-family: 'times'; font-size:12pt")))
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
		h4(legend6[1]),
		
			
		# ==== About section
		fluidRow(align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				helpText( strong(legend6[2] , style="color:Orange ; font-family: 'times'; font-size:30pt ; font-type:bold" )) ,
				hr()
		)),
		fluidRow(
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(3,offset=3, align="justify",
				br(),
				legend6[3],
				br()
				),
			column(3,offset=0, align="justify",
				br(),
				legend6[4],
				br()
		)), br(),br(),





		# ==== Input files description
		fluidRow(align="center",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				helpText( strong(legend6[5] , style="color:Orange ; font-family: 'times'; font-size:30pt ; font-type:bold" )) ,
				hr()
		)),
		fluidRow(align="justify",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				legend6[6],
				br()
				)), 
		br(),
		fluidRow( 
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(3,offset=1,align="center",
				br(),br(),
				a("OneMap",href="https://cran.r-project.org/web/packages/onemap/onemap.pdf", target="_blank")," [1] format: 3 columns: linkage group, marker name and position in the map.",
				downloadLink("load_ex_format1", label = "Download"),br(),
				dataTableOutput('doc_ex1' , width="100px"),
				br()
				),
			column(3,offset=1,align="center",
				br(),
				a("MapChart",href="http://jhered.oxfordjournals.org/content/93/1/77.full", target="_blank")," [2] format: composed of a sequence of linkage groups, each with a header specifying the linkage group title, followed by a sequence of lines with locus names and map positions.",
				downloadLink("load_ex_format2", label = "Download"),
				dataTableOutput('doc_ex2' , width="100px"),
				br()
				),
			column(3,offset=1,align="center",
				br(),
				a("Carthagène",href="http://www7.inra.fr/mia/T/CarthaGene/", target="_blank"), " [3] format: 1 line only. Linkage groups are separated with {}. Then marker names and positions are provided successively. Output created with the \'mapget\' command.",
				downloadLink("load_ex_format3", label = "Download"),br(),
				dataTableOutput('doc_ex3' , width="300px"),
				br()
				)
		
		), br(),



		# ==== Use the app locally
		fluidRow(align="center",
			style="opacity: 1;background-color:white; margin-top: 0px;width: 100%;",
			column(6,offset=3,
				# Set the style of this page
				br(),
				helpText(strong(legend6[11] , style="color:orange ; font-family: 'times'; font-size:30pt ; font-type:bold" ) ) ,
				hr()
			)),
		fluidRow(align="justify",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				legend6[12],br(),br(),
				legend6[13],a("Install R",href="https://www.r-project.org/", target="_blank"),legend6[16],br(),br(),
				legend6[14],br(),
				code("install.packages(shiny)"),br(),
				code("library(shiny)"),br(),br(),
				legend6[15],br(),
				code("runGitHub(\"GenMap-Comparator\",\"holtzy\")"),br(),
				br(),br()
				)
			),





		# ==== Contact
		fluidRow(align="center",
			style="opacity: 1;background-color:white; margin-top: 0px;width: 100%;",
			column(6,offset=3,
				# Set the style of this page
				br(),
				helpText(strong(legend6[10] , style="color:orange ; font-family: 'times'; font-size:30pt ; font-type:bold" ) ) ,
				hr()
			)),
		fluidRow( align="center",
			style="opacity: 1;background-color:white; margin-top: 0px;width: 100%;",
			column(3,offset=3,
				img(src="map_montpellier.png" ,  width = 500),
				br()
				),
			column(3,offset=1,
				br(),
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
		fluidRow( style=" opacity: 0.8 ; background-color: white ; margin-top: 0px ; width: 100%; "  ), br(),
		
		
		
		# ==== References
		fluidRow(align="center",
			style="opacity: 1;background-color:white; margin-top: 0px;width: 100%;",
			column(6,offset=3,
				# Set the style of this page
				br(),
				helpText(strong("- References -" , style="color:orange ; font-family: 'times'; font-size:30pt ; font-type:bold" ) ) ,
				hr()
			)),
		fluidRow(align="left",
			style="opacity:0.9; background-color: white ;margin-top: 0px; width: 100%;",
			column(6,offset=3,
				br(),
				"1. Margarido GRA, Souza AP, Garcia AAF. OneMap: software for genetic mapping in outcrossing species. Hereditas. Wiley Online Library; 2007;144: 78–79.", br(),
				"2. Lander ES, Green P, Abrahamson J, Barlow A, Daly MJ, Lincoln SE, et al. MAPMAKER: an interactive computer package for constructing primary genetic linkage maps of experimental and natural populations. Genomics. Elsevier; 1987;1: 174–181.", br(),
				"3. de Givry S, Bouchez M, Chabrier P, Milan D, Schiex T. CARTHAGENE: Multipopulation integrated genetic and radiation hybrid mapping. Bioinformatics. 2005;21: 1703–1704.", br(),
				br(), br()
			)),


		
		# === Last bandeau for the logos
		fluidRow(
			
			# Set the style of this page
			style=" opacity: 0.8 ; background-color: black ; margin-top: 0px ; width: 100%; ",
		
			# put the logos
			br(),
			column(2, offset=2, img(src="logo_INRA.png" ,  height = 70*grand, width = 120*grand) , br(),br() ),
			column(2, offset=1, img(src="logo_SUPAGRO.jpg" ,  height = 70*grand, width = 120*grand) ),
			column(2, offset=1, img(src="logo_arvalis.png" ,  height = 70*grand, width = 110*grand) )
			
			)

		#Close the tabPanel
		)

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





#Close the shinyUI
))


