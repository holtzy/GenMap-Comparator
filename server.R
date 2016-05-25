
#fregssthtrs

		################################################
		#
		#		THE GENETIC MAP COMPARATOR
		#
		###############################################



# OPEN THE SHINY SERVER
shinyServer(function(input, output, session) {


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- UNDERSTAND WHICH IS THE SELECTED FOLDER
#-----------------------------------------------------------------------------

	# I use a widget found on the web: https://github.com/wleepang/shiny-directory-input
	observeEvent(
	  ignoreNULL = TRUE,
	  eventExpr = {
		input$directory
	  },
	  handlerExpr = {
		if (input$directory > 0) {
		  # condition prevents handler execution on initial app launch the directory selection dialog with initial path read from the widget
		  path = choose.dir(default = readDirectoryInput(session, 'directory'))
		  # update the widget value
		  updateDirectoryInput(session, 'directory', value = path)
		}})
	# Now I have the selected path! I can call it doing "readDirectoryInput(session, 'directory')" in a reactive environment!

	# So I do a reactive variable containing the path:
	my_path=reactive({
		my_path=readDirectoryInput(session, 'directory')
		return(my_path)
		})
	#I have to cal my_path() somewhere to have the current path

	observe({
		print("mon path sélectionnés")
		print(my_path() )
		})

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

	
	



#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- UPLOAD MAPS AND FILE FORMATING
#-----------------------------------------------------------------------------

	# 1/ --- Catch the map names we have to compare :
	MY_map_files=reactive({
		map_files=list.files( my_path() )
		return(map_files)
		})
		
	observe({
		print("mes maps selectionnées")
		print ( MY_map_files()  )
		})

	
		
	# 2/ --- Load every maps and add their content in a list. (I keep only the first 3 columns, and I order the maps by LG and positions)
	MY_maps=reactive({
		
		# Get back the reactive objects:
		map_files=MY_map_files()
		nb_de_carte=length(map_files)
		my_path=my_path()
		
		# read and format maps one by one:
		my_maps=list()
		for(i in c(1:nb_de_carte)){
			
			# Load the map
			map_tmp=read.table(paste(my_path,map_files[i],sep="") , header=T , dec="." ,na.strings="NA")[,c(1:3)]
					
			# Columns must be in the good format:
			map_tmp[,1]=as.factor(map_tmp[,1])
			map_tmp[,2]=as.factor(map_tmp[,2])
			map_tmp[,3]=as.numeric(as.character(map_tmp[,3]))
			
			# With the good names:
			colnames(map_tmp)=c("group","marker","position")	
			
			# I remove positions where an information is missing:
			map_tmp=na.omit(map_tmp)
			
			# And ordered
			map_tmp=map_tmp[order(map_tmp$group , map_tmp$position ) , ]
			
			# Add it to the list
			my_maps[[length(my_maps)+1]]=map_tmp
		
		}
		return(my_maps)
		
		# If you want to see informations concerning the map number1 : nrow(my_maps[[1]])
		# If you want the name of the map number one : print(map_files[1])	
		
	})
	
	
	observe({
		print("summary de la carte 1:")
		#print ( head(MY_maps()[1])  )
		})
	
	
	# 3/ --- Merge the maps together
	MY_data=reactive({
		
		#Get back the reactive objects needed:
		my_maps=MY_maps()
		nb_de_carte=length(my_maps)
		map_files=MY_map_files()

		#Do the Merge
		data=merge(my_maps[[1]] , my_maps[[2]], by.x=2 , by.y=2 , all=T)
		colnames(data)=c("marker",paste("chromo",map_files[1],sep="_") , paste("pos",map_files[1],sep="_") , paste("chromo",map_files[2],sep="_") , paste("pos",map_files[2],sep="_"))
		if(nb_de_carte>2){
			for(i in c(3:nb_de_carte)){
				data=merge(data , my_maps[[i]] , by.x=1 , by.y=2 , all=T)
				colnames(data)[c( ncol(data)-1 , ncol(data) )]= c( paste("chromo",map_files[i],sep="_") , paste("pos",map_files[i],sep="_") )
			}}
		
		# I have now a file summarizing the information for every markers present at least one time ! Return it!
		return(data)
	})
		
	observe({
		print("summary du fichier mergé data:")
		print ( head( MY_data() )  )
		})
		
		
		
	# 4/ --- List of chromosomes ?
	MY_chromosome_list=reactive({

		#Get back the reactive objects needed:
		data=MY_data()

		# --- Get a list with the existing chromosomes:
		chromosome_list=unlist(data[ , seq(2,ncol(data),2) ])
		chromosome_list=as.character(unique(sort( chromosome_list[!is.na(chromosome_list)] )))
		
		# Return the chromosome liste
		return(chromosome_list)
		})

	observe({
		print("Liste des chromosomes:")
		print ( head( MY_chromosome_list() )  )
		})

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
		
		







#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
		
#-----------------------------------------------------------------------------
# --- COMPUTE SUMMARY STATISTICS FOR EVERY MAPS
#-----------------------------------------------------------------------------

	MY_summary_stat=reactive({
		
		# Get the needed reactive objects:
		my_maps=MY_maps()
		nb_de_carte=length(my_maps)

		# Function 1 : give it a piece of map, it calculates some statistics and add it to a bilan data frame.
		my_fun=function(my_map, bilan, i){
			num=nrow(bilan)
			num=num+1
			bilan[num,1]=i
			bilan[num,2]=nrow(my_map)
			bilan[num,3]=max(my_map[,3])
			# Calcul des gaps: je vais prendre les gaps entre position unique, pas les gaps entre chaque marqueurs !
			gaps = sort(my_map[,3])[-1] - sort(my_map[,3])[-length(my_map[,3])] 
			gaps=gaps[gaps!=0]
			bilan[num,4]=mean(gaps)
			bilan[num,5]=max(gaps)
			bilan[num,6]=nrow(unique(my_map[,c(1,3)]))
			return(bilan)
			}
		
		# Compute summary statistics for every maps applying this function !
		summary_stat=list()
		for(j in 1:nb_de_carte){
			# Make an emty matrix
			map=my_maps[[j]]			
			bilan=data.frame(matrix(0,0,6)) ; num=0
			colnames(bilan)=c("Chromo","nbr marker","size","average gap","biggest gap","Nb uniq pos")
			# Apply the my_fun function to each chromosome one by one
			for(i in levels(map[,1])){
				map_K=map[map[,1]==i,]
				bilan=my_fun(map_K , bilan , i)
				}
			# And then to the whole map
			i="tot"
			bilan=my_fun(map , bilan , "all")
			#Add the result to the list containing all the map summaries
			summary_stat[[length(summary_stat)+1]]=bilan
			}
		
		# If I want the summary of the first map : summary_stat[[1]]
		return(summary_stat)
	
	})
		
	observe({
		print("fichier de summary statistique:")
		for(u in MY_summary_stat()) {print ( u  )}
		})
		
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

		
		







#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

# --------------------------------------------------------------------------------
# 	CREATION OF THE DYNAMICS BUTTONS FOR THE UI SCRIPT
#--------------------------------------------------------------------------------


  # ======== sheet2: Summary Statistics =========
  # MAP to study
  output$choose_maps_sheet2<- renderUI({ checkboxGroupInput("selected_maps_sheet2", "Choose maps !", choices=MY_map_files(), selected=c(MY_map_files()[1],MY_map_files()[2]) ) })
  # Chromosomes to study
  output$choose_chromo_sheet2<- renderUI({checkboxGroupInput( "chromo_sheet2", legend[5], choices=MY_chromosome_list() , selected =c(MY_chromosome_list()[1],MY_chromosome_list()[2]) , inline = TRUE ) })


  # ======== sheet3: Compare Positions =========
  # Map to study
  output$choose_maps3<- renderUI({ checkboxGroupInput("selected_maps", "Choose maps !", choices=MY_map_files(), selected=c(MY_map_files()[1],MY_map_files()[2]) ) })
  # Chromosomes to study
  output$choose_chromo_sheet3<- renderUI({selectInput( "chromo", legend[5], choices=MY_chromosome_list() , selected =MY_chromosome_list()[1] ) })


  # ======== sheet4: Interchromosomal Analyse =========
  # First map to study :
  output$map1<- renderUI({ radioButtons("map1", "Choose a first map", choices=MY_map_files(), selected=MY_map_files()[1] ) })
  # Second map to study :
  output$map2<- renderUI({ radioButtons("map2", "Choose a second map", choices=MY_map_files(), selected=MY_map_files()[2] ) })
  # Chromosomes to study
  output$choose_chromo_sheet4<- renderUI({   selectInput( "chromo_sheet4", legend[10], choices=c("all", MY_chromosome_list()) , selected =c("all") )  })


  # ======== sheet5: Rough Map vizualisation =========
  # MAP to study
  output$choose_maps5<- renderUI({ radioButtons("selected_maps_sheet5", "Choose the reference map!", choices=MY_map_files(), selected=MY_map_files()[1] ) })
  # Chromosomes to study
  output$choose_chromo_sheet5<- renderUI({   checkboxGroupInput( "chromo_sheet5", legend[13], choices=c("all", MY_chromosome_list()) , selected =c(MY_chromosome_list()[1],MY_chromosome_list()[2]) , inline = TRUE )     })
  


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

























#Je ferme le shinyServer
})

