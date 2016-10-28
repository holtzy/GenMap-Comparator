

		################################################
		#
		#		THE GENETIC MAP COMPARATOR
		#
		###############################################


# OPEN THE SHINY SERVER
shinyServer(function(input, output, session) {





#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- ALLOWS USER TO DOWNLOAD EXAMPLE DATASET
#-----------------------------------------------------------------------------


# format OneMap
output$load_ex_format1 <- downloadHandler(
    filename = "GenMapComp_Example1.csv",
	content <- function(file) {
    	file.copy("DATA/EX_HELP_PAGE/Example_Data_Set1.csv", file)
  		}  
  	)


#format Mapchart
output$load_ex_format2 <- downloadHandler(
    filename = "GenMapComp_Example2.csv",
	content <- function(file) {
    	file.copy("DATA/EX_HELP_PAGE/Example_Data_Set2.csv", file)
  		}  
  	)

#format Carthagène
output$load_ex_format3 <- downloadHandler(
    filename = "GenMapComp_Example3.csv",
	content <- function(file) {
    	file.copy("DATA/EX_HELP_PAGE/Example_Data_Set3.csv", file)
  		}  
  	)

  
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#






  
  

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- UPLOAD MAPS AND FILE FORMATING
#-----------------------------------------------------------------------------

	
	
	# 0/ --- Selection of the data set: default dataset / Example dataset / Chosen dataset
	inFile=reactive({
		
		# Cleaning
		rm(list=ls())
		my_global_old_choice <- c(3)
		
		
		# If nothing is choosen I take the chosen exemple dataset
		if ( is.null(input$file1)) {
			
			if( input$file2=="sorghum (Mace et al. 2009)" | is.null(input$file2)){ inFile=data.frame(name=as.character(c("CIRAD","S2","S4","S5","S6","TAMU")) , datapath=as.character(c("DATA/SORGHUM/CIRAD", "DATA/SORGHUM/S2" , "DATA/SORGHUM/S4" , "DATA/SORGHUM/S5" , "DATA/SORGHUM/S6" , "DATA/SORGHUM/TAMU" )) ) }
			else if( input$file2=="wheat (Maccaferri et al. 2015)"){  inFile=data.frame(name=as.character(c("Ben_Pi41025","Colosseo_Lloyd","Kofa_svevo","Langdon_G1816","Latino_MG5323","Mohawk_Cocorrit69","Simeto_Levante")) , datapath=as.character(c("DATA/WHEAT_MACAF/CLEAN/Ben_Pi41025", "DATA/WHEAT_MACAF/CLEAN/Colosseo_Lloyd" , "DATA/WHEAT_MACAF/CLEAN/Kofa_svevo", "DATA/WHEAT_MACAF/CLEAN/Langdon_G1816", "DATA/WHEAT_MACAF/CLEAN/Latino_MG5323", "DATA/WHEAT_MACAF/CLEAN/Mohawk_Cocorrit69", "DATA/WHEAT_MACAF/CLEAN/Simeto_Levante" )) ) }
			else if( input$file2=="wheat (Holtz et al. 2016)"){  inFile=data.frame(name=as.character(c("map_DS","map_DL","map_consensus","physical_position")) , datapath=as.character(c("DATA/WHEAT_TRAM/map_DS","DATA/WHEAT_TRAM/map_DL","DATA/WHEAT_TRAM/map_consensus","DATA/WHEAT_TRAM/physical_position" )) ) }
				
		}else{
			
			# If the user choose a dataset, I take this dataset:
			inFile <- input$file1
			
		}
				
	})
		
	# Check it worked properly
	#observe({ print("Mon inFile") ; print ( inFile() ) ; print("--") 	})






	# 1/ --- Catch the map names we have to compare :
	MY_map_files=reactive({

		# List of map files:
		map_files=as.list(inFile()$name)
		# return this list, but do not forget to format it:
		return(as.character(unlist(map_files)))
		})

	# Check it worked properly
	#observe({ print("mes maps selectionnées") ; print ( MY_map_files()) ; print("test widget selection") ; selected=c(MY_map_files()[1],MY_map_files()[2]) ; print(selected) 	})

		





	# 2/ --- Load every maps and add their content in a list.
	MY_maps=reactive({
	
	
		# I am reactive to the selection of input files !
		inFile=inFile()
		#print("......... repeat ........")
		

		# Read and format maps one by one, and add them to a list:
		my_maps=list()
		for(i in inFile$datapath){
						
			# Load the map
			map_tmp=read.table(i , header=T , dec="." ,na.strings="NA")
	
			# If I have only 1 column, the separator was wrong, I try with ";":
			if(ncol(map_tmp)==1){
				map_tmp=read.table(i , header=T ,  dec="." ,na.strings="NA" , sep=";")
			}
			
			# If I have 2 columns, It is the MAPCHART format --> I need to reformat it!
			if(ncol(map_tmp)==2){
				junctions=c(1, as.numeric(row.names(map_tmp[map_tmp[,1]=="group" , ])), nrow(map_tmp)+1 )
				nb_rep=junctions[-1] - junctions[-length(junctions)]
				LG_names=c(colnames(map_tmp)[2] , as.character(map_tmp[map_tmp[,1]=="group" , 2]) )
				map_tmp$new=rep(LG_names , times=nb_rep)
				map_tmp=map_tmp[map_tmp[,1]!="group" , ]
				map_tmp=map_tmp[ , c(3,1,2)]
				}
			
			
			# If I have only 0 line, it is the CARTHAGENE Format --> I need to reformat it!
			if(nrow(map_tmp)==0){
				tmp_data=read.table(i , header=F , sep=" ")
				tmp_data=apply(tmp_data, 2 , as.character)
				tmp_data=gsub("\\}" , "" , tmp_data )
				tmp_data=tmp_data[-c(1,2)]
				map_tmp=data.frame(matrix(0, length(tmp_data), 3))
				num=0
				for(k in tmp_data){
					# If the LG changes, I change my "LG" variable, and num1 back to -2
					if( substr(k,1,1) == "{" ){
						LG=gsub("\\{","",k)
						num1=-2
						}
					# For each step of the loop, num1 increases
					num1=num1+1
					# When I am not reading a LG name (num1=-2) or a likelihood (num1=0), I add stuff in my map_tmp table
					# The line number (num) increase only once every 2 iterations
					if( num1>0){
						num=num+num1%%2
						map_tmp[num,1]=LG
						map_tmp[num,num1%%2+2]=k
				}}
				# Clean this map_tmp
				map_tmp=map_tmp[ c(1:num) , c(1,3,2)]			
				}
			
					
			# Columns must be in the good format:
			map_tmp[,1]=as.factor(map_tmp[,1])
			map_tmp[,2]=as.factor(map_tmp[,2])
			map_tmp[,3]=as.numeric(as.character(map_tmp[,3]))
			
			# With the good names:
			colnames(map_tmp)=c("group","marker","position")	

			# I keep only the first 3 columns (if they are more..)
			map_tmp=map_tmp[,c(1:3)]
						
			# I remove positions where an information is missing:
			map_tmp=na.omit(map_tmp)
			
			# And ordered
			map_tmp=map_tmp[order(map_tmp$group , map_tmp$position ) , ]
			
			# Add it to the list
			my_maps[[length(my_maps)+1]]=map_tmp
		
		}
		return(my_maps)
		
	})
		
	# Check everything worked properly
	observe({ print("summary de la carte 1:") ;	print ( head(MY_maps()[[1]])  ) 	})
	







	# 3/ --- Merge the maps together
	MY_data=reactive({
	
		# Get back the reactive objects needed:
		my_maps=MY_maps()
		nb_de_carte=length(my_maps)
		map_files=MY_map_files()

		# Merge the n maps together:
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
		
	# Check everything worked properly
	#observe({ print("summary du fichier mergé data:") ; print ( head( MY_data() )  )  })







	# 4/ --- List of chromosomes ?
	MY_chromosome_list=reactive({

		# Get back the reactive objects needed:
		data=MY_data()

		# --- Get a list with the existing chromosomes:
		chromosome_list=unlist(data[ , seq(2,ncol(data),2) ])
		chromosome_list=as.character(unique(sort( chromosome_list[!is.na(chromosome_list)] )))
		
		# Return the chromosome liste
		return(chromosome_list)
		})

	# Did it work ?
	#observe({ print("Liste des chromosomes:") ; print ( head( MY_chromosome_list() )  ) })

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
			bilan[num,4]=round(mean(gaps),2)
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
			colnames(bilan)=c("Chr.","#markers","map_size","average gap_size","biggest gap_size","#unique positions")
			# Apply the my_fun function to each chromosome one by one
			for(i in levels(map[,1])){
				map_K=map[map[,1]==i,]
				bilan=my_fun(map_K , bilan , i)
				}
			# And then to the whole map
			i="tot"
			bilan=my_fun(map , bilan , "all")
			#Correct map size
			bilan[nrow(bilan) , 3] = sum(bilan[ -nrow(bilan) ,3])
			#Add the result to the list containing all the map summaries
			summary_stat[[length(summary_stat)+1]]=bilan
			}
		
		# If I want the summary of the first map : summary_stat[[1]]
		return(summary_stat)
	
	})
		
	# Check if everything is all right
	#observe({ print("fichier de summary statistique:") ; for(u in MY_summary_stat()) {print ( u  )}     })
		
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

		
		






#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

# --------------------------------------------------------------------------------
# 	CREATION OF THE DYNAMICS BUTTONS FOR THE UI SCRIPT
#--------------------------------------------------------------------------------


  # ======== sheet2: Summary Statistics =========
  # MAP to study
  output$choose_maps_sheet2<- renderUI({ checkboxGroupInput("selected_maps_sheet2", legend2[9], choices=MY_map_files(), selected=c(MY_map_files()[1],MY_map_files()[2]) , inline=T) })
  # Chromosomes to study for markers density
  output$choose_chromo_sheet2<- renderUI({checkboxGroupInput( "chromo_sheet2", legend2[10], choices=MY_chromosome_list() , selected =c(MY_chromosome_list()[1],MY_chromosome_list()[2]) , inline = TRUE ) })
  # Map to study for summary table
  output$choose_maps_sheet2_bis<- renderUI({ radioButtons("selected_maps_sheet2_bis", legend2[11], choices=MY_map_files(), selected=c(MY_map_files()[1]) , inline=T) })
  

  # ======== sheet3: Compare Positions =========
  # Map to study
  output$choose_maps3<- renderUI({ checkboxGroupInput("selected_maps", legend3[4], choices=MY_map_files(), selected=c(MY_map_files()[1],MY_map_files()[2]) , inline=T) })
  # Chromosomes to study
  output$choose_chromo_sheet3<- renderUI({ radioButtons( "chromo", legend3[5], choices=MY_chromosome_list() , selected =MY_chromosome_list()[1] , inline=T ) })


  # ======== sheet4: Interchromosomal Analyse =========
  # First map to study :
  output$map1<- renderUI({ radioButtons("map1", legend4[4], choices=MY_map_files(), selected=MY_map_files()[1] ) })
  # Second map to study :
  output$map2<- renderUI({ radioButtons("map2", legend4[5], choices=MY_map_files(), selected=MY_map_files()[2] ) })
  # Chromosomes to study
  output$choose_chromo_sheet4<- renderUI({   selectInput( "chromo_sheet4", legend4[6], choices=c("all", MY_chromosome_list()) , selected =c("all") )  })


  # ======== sheet5: Rough Map vizualisation =========
  # MAP to study
  output$choose_maps5<- renderUI({ radioButtons("selected_maps_sheet5", legend5[3], choices=MY_map_files(), selected=MY_map_files()[1] ) })
  # Chromosomes to study
  output$choose_chromo_sheet5<- renderUI({   checkboxGroupInput( "chromo_sheet5", legend5[4], choices=c("all", MY_chromosome_list()) , selected =c(MY_chromosome_list()[1],MY_chromosome_list()[2]) , inline = TRUE )     })
  
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#










#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 2 : SUMMARY STATISTICS PAGE - BARPLOT !
#-----------------------------------------------------------------------------


	output$my_barplot=renderPlot({ 
	
		# Get the needed reactive objects:
		summary_stat=MY_summary_stat()
		map_files=unlist(MY_map_files())
				
 		# Selected variable ?
		#VRselected_var=which(c("nb. marker","size","average gap","biggest gap","Nb. uniq pos.")%in%input$var_for_barplot)
		selected_var=which(c("# markers","map size","average gap size","biggest gap size","# unique positions")%in%input$var_for_barplot)
		
		# Selected Maps ?
		selected_maps=which(map_files%in%input$selected_maps_sheet2)
		nb_selected_maps=length(selected_maps)
		
		# Create a table which gives this selected_variable for every selected maps and every chromosomes.
		barplot_table=summary_stat[[selected_maps[1]]] [,c(1,selected_var+1)]
		for(i in selected_maps[-1]){
			barplot_table=merge(barplot_table , summary_stat[[i]] [,c(1,selected_var+1)] , by.x=1 , by.y=1 , all=T)
			}
		rownames(barplot_table)=barplot_table[,1]
		barplot_table=barplot_table[-nrow(barplot_table) , ]
		barplot_table=t(as.matrix(barplot_table[,-1]))
		
		# Make the barplot !
		par(mar=c(3,3,3,8))
		barplot(barplot_table , beside=T , col=my_colors[1:length(selected_maps)]) 
		#mtext(legend[23] , col="#3C3C3C" , line=-3 , at=ncol(barplot_table)*nb_selected_maps+8)
		
	#Close the render-barplot 
	})

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#







#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 2 : SUMMARY STATISTICS PAGE - DONUT-PLOT !
#-----------------------------------------------------------------------------

	output$my_pieplot=renderPlot({

		# Get the needed reactive objects:
		summary_stat=MY_summary_stat()
		map_files=MY_map_files()
	
		# Avoid bug when loading
  		if (is.null(input$var_for_barplot) | is.null(input$selected_maps_sheet2) ) {return(NULL)}

		# Selected variable ?
		#all_var=c("nb. marker","size","average gap","biggest gap","Nb. uniq pos.")
		all_var=c("# markers","map size","average gap size","biggest gap size","# unique positions")
		selected_var=which(all_var%in%input$var_for_barplot)

		# Selected Maps ?
		selected_maps=which(map_files%in%input$selected_maps_sheet2)
		nb_selected_maps=length(selected_maps)
		
		# Create a table which gives this selected_variable for every selected maps and every chromosomes.
		barplot_table=summary_stat[[selected_maps[1]]] [,c(1,selected_var+1)]
		for(i in selected_maps[-1]){
			barplot_table=merge(barplot_table , summary_stat[[i]] [,c(1,selected_var+1)] , by.x=1 , by.y=1 , all=T)
			}
		rownames(barplot_table)=barplot_table[,1]
		barplot_table=barplot_table[nrow(barplot_table) , ]
		barplot_table=t(as.matrix(barplot_table[,-1]))
		
		# Make the donut-plot !
		par(mar=c(3,3,3,10))
		my_labels=paste(map_files[selected_maps],"\n",all_var[selected_var]," : ",barplot_table,sep="")
		doughnut(barplot_table, col=my_colors , border="white" , inner.radius=0.5, labels=my_labels )
		#mtext(expression(italic(legend[24])) , col="#3C3C3C" , line=-5)
	
	#Close the render-barplot 
	})


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#








#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 2 : SUMMARY STATISTICS PAGE - SUMMARY TABLE OF SELECTED MAP
#-----------------------------------------------------------------------------


		observe({

			# Selected Map ?
			selected_map=which(MY_map_files()%in%input$selected_maps_sheet2_bis)
			
  			# Avoid bug when loading
  			if (is.null(input$selected_maps_sheet2_bis) ) {return(NULL)}

			# Get the desired summary stat
			toprint=MY_summary_stat()[[selected_map]]
	
			output$sum_table <- DT::renderDataTable(
					DT::datatable( toprint , rownames = FALSE , options = list(pageLength = 40, dom = 't' ))
			)
		
		# Close observer
		})
	

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#











#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 2 : SUMMARY STATISTICS PAGE - CIRCULAR PLOT FOR DENSITY !
#-----------------------------------------------------------------------------

	# Make the circular plot. See https://cran.r-project.org/web/packages/circlize/vignettes/circlize.pdf to understand how circular plot works.
  	output$circular_plot <- renderPlot({ 

		# Get the needed reactive objects:
		summary_stat=MY_summary_stat()
		map_files=MY_map_files()
  		my_maps=MY_maps()
  		nb_de_carte=length(map_files)
  		
		# Avoid bug when loading
  		if (is.null(input$var_for_barplot) | is.null(input$selected_maps_sheet2) ) {return(NULL)}

		# Which maps have been selected ?
		selected_maps=which(map_files%in%input$selected_maps_sheet2)
		nb_selected_maps=length(selected_maps)
				
		# Fichier nécessaire
		data_circ=data.frame()
		for(i in selected_maps){
				current_map=my_maps[[i]]
				current_map$map_name=map_files[i] 
				current_map$group_and_name=paste(map_files[i] , current_map[,1] , sep="_")
				data_circ=rbind(data_circ , current_map)
			}

		
		# If the "all" option is not selected, then I keep only the chosen chromosomes
		if(!("all"%in%input$chromo_sheet2)){
			take=which(data_circ[,1]%in%input$chromo_sheet2)
			data_circ=data_circ[take , ]
			data_circ[,1]=droplevels(data_circ[,1])
			}		
		

		# Réalisation du graph
		par(mfrow=c(nb_de_carte ,1) , mar=c(0.3,4,0,0) )
		for( map in levels(as.factor(data_circ$map_name))){
		
			# Reset x positions
			vecX=c()
			vecY=c()
			vecSep=c(0)
			my_data=data_circ[which(data_circ$map_name==map) , ]
			
			for( chromo in levels(as.factor(my_data$group)) ){
			
			 	 don=my_data[which(my_data$group==chromo) , ]
			 	 a=density(don$position)
				 a$x=a$x + abs(min(a$x)) 
				 if(length(vecX)>0){a$x=a$x+max(vecX) }
				 vecX=c(vecX , a$x)
				 vecY=c(vecY , a$y)
				 vecSep=c(vecSep, max(vecX)) 
			 }
			 
			 # print the plot
			 plot(1,1,col="transparent" , xlim=c(0,max(vecX)) , ylim=c(0,max(vecY)) , xlab="" , xaxt="n" , ylab="" , yaxt="n" , bty="n" )
			 rect(  vecSep[-length( vecSep)], rep(-2,length( vecSep)) ,  vecSep[-1] , rep(1 , length( vecSep))  , col=my_colors , border=F )
			 lines( vecX , vecY  , col="orange" , lwd=3 )
	 		 mtext( map , at=max(vecY)/2 , col="orange" , cex=2 , line=0, side=2 )

 		#fin du plot
 		}
 		
 		#Ajout des labels de l'axe des x?
		mtext( levels(as.factor(my_data$group)) , at=(vecSep[-1]+vecSep[-length(vecSep)]) /2 , col="orange" , cex=2 , line=5, side=1 )
			
		})
	
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#











#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 3 : MAP COMPARISON FOR A CHOSEN CHROMOSOME
#-----------------------------------------------------------------------------



	# define session specific variable
	# visible from all functions but session/user specific 
	my_global_old_choice<-c();
	liste_of_map_to_compare<-c();


	# liste_of_map_to_compare is an object with the genetic maps to compare, in the good order. I initialize it with the 2 first maps, like in the radiobutton.
	MY_liste_of_map_to_compare=reactive({
		map_files=MY_map_files()
		liste_of_map_to_compare=c(map_files[1],map_files[2])
		return(liste_of_map_to_compare)
		})
 	
  
  	
    output$plot1 <- renderPlotly({ 

    	
		# Get the needed reactive objects:
		#VR liste_of_map_to_compare=MY_liste_of_map_to_compare()
		summary_stat=MY_summary_stat()
		map_files=MY_map_files()
  		my_maps=MY_maps()
  		nb_de_carte=length(map_files)
    	data=MY_data()
   		
   		old_choice <- my_global_old_choice;

   		# --- Avoid bug when page is loading
  		#VR if (is.null(input$selected_maps)) {return(NULL)}


  		# I get the current choice of maps to show:
		#current_choice=reactive({ return(input$selected_maps) })
		current_choice=input$selected_maps

		print("")
		print("===the old choice was :")
		print(old_choice)
		print("===the current choice is :")
		print(current_choice)

		
		# If the user has added a map, I determine which, and add it to the map to compare:
		#VR
		if(is.null(old_choice) | is.null(current_choice) )
		{
			#print("=IF")
			liste_of_map_to_compare=current_choice
		}
		else
		{
			#print("=ELSE")
			intersection=which(old_choice%in%current_choice)
			if( length(intersection)==0 ){
				to_del=old_choice
			}else{
				to_del=old_choice[-intersection]
				}
			#print("TODEL")
			#print(to_del)

			if(length(to_del)>0)
				{liste_of_map_to_compare=old_choice[ - which(old_choice%in%to_del) ]}
			#print("AFTERDEL")
			#print(liste_of_map_to_compare)

			intersection=which(current_choice%in%old_choice)			
			if( length(intersection)==0 ){
				to_add= current_choice
			}else{
				to_add= current_choice[-intersection]
				}				
			#print("TOADD")
			#print(to_add)

			if(length(to_add)>0)
			liste_of_map_to_compare=c(liste_of_map_to_compare,to_add)
			print("AFTERADD NEW LIST")
			print(liste_of_map_to_compare)
		}
		# I save the current choice as old_choice for next change:
		#old_choice<<-liste_of_map_to_compare
		my_global_old_choice<<-liste_of_map_to_compare
		liste_of_map_to_compare<<-liste_of_map_to_compare
		
		
		
		print("+++the ordered current choice is :")
		print(liste_of_map_to_compare)
				
		# To avoid a bug, when only ONE map is selected, the map to compare is this map:
		#VR if(length(current_choice)==1){  liste_of_map_to_compare<<-current_choice }
		
		#fin VR


		# --- Make an input table with columns in the corresponding order: from mapB,mapA i keep column: 1, 4,5, 2,3:
		selected_maps=match(liste_of_map_to_compare , map_files)  
		selected_col=rep(selected_maps , each=2)*2
		selected_col=c(1,selected_col+rep(c(0,1) , length(selected_col)/2))
		dat=data[ , selected_col ]
		nb_selected_maps=length(selected_maps)
		print("nb map")
		print(nb_selected_maps)
		
		# VR 
		if(nb_selected_maps<2){
		return (NULL)
		#liste_of_map_to_compare=c(map_files[1],map_files[2])
		}

		# --- Subset of the dataset with only the good chromosome :
		don=dat[dat[,2]==input$chromo & !is.na(dat[,2]) , ]
		for(j in c(2:nb_selected_maps)){
			temp=dat[dat[,c((j-1)*2+2)]==input$chromo & !is.na(dat[,c((j-1)*2+2)]) , ]
			don=rbind(don,temp)
		}
		don=unique(don)
		
		
		# --- OBJET 1 POUR LES LIAISONS ENRTE MARQUEURS
		#Je fais une fonction qui me fait mon vecteur de position pour 2 cartes données : AXE des Y
		function_pos=function(x,y){
			#Récupération de 2 carte seulement:
			pos=as.matrix(na.omit(don[,c(x,y)]))
			
			#Il faut que je fasse un vecteur avec les valeur en cM dans l'ordre
			my_vect=as.vector(t(pos))
			correctif=seq(1:length(my_vect)) + rep(c(0,0,1,-1) , length.out=length(my_vect) )  
			my_vect=my_vect[correctif]
			
			#Mais attention probleme! si je fini sur la carte de gauche, il faut que je revienne a la carte de droite avant de passer a la paire de carte suivante!
			if(length(my_vect)%%4 == 0){ my_vect=c(my_vect , my_vect[length(my_vect)] , my_vect[length(my_vect)-1]) } 

			return(my_vect)
			}
			
		# --- J applique a toutes les cartes sélectionnées, j obtiens un maxi vecteur.
		pos_final=c()
		for(v in c(1:(nb_selected_maps-1))){
			col_x=v*2+1
			col_y=v*2+3
			a=function_pos( col_x , col_y)
			pos_final=c(pos_final,a)
			}
				
		#Et je dois faire le vecteur de l'axe des X !
		xaxis=c()
		num=0
		for(i in c(1:(nb_selected_maps-1))){
			num=num+1
			my_nb=nrow(na.omit(don[,c(i*2+1,i*2+3)]))
			to_add=rep(c(num,num+1,num+1,num),my_nb/2)
			if(length(to_add)%%4 == 0){ to_add=c(to_add , to_add[length(to_add)] , to_add[length(to_add)-1]) } 
			xaxis=c(xaxis,to_add)
			}


		# Start the plotly graph
		p=plot_ly(x=xaxis , y=pos_final , hoverinfo="none" , type="scatter", mode="lines",  line=list(width=input$thickness, color=input$my_color , opacity=0.1) , showlegend=F)%>%   

		# Custom the layout
		layout( 
			#Gestion du hovermode
			hovermode="closest"  ,
			# Gestion des axes
			xaxis=list(title = "", zeroline = FALSE, showline = FALSE, showticklabels = FALSE, showgrid = FALSE , range=c(0.5,nb_selected_maps+0.5) ),
			yaxis=list(range=c(0,500), autorange = "reversed", title = "Position (cM)", zeroline = F, showline = T, showticklabels = T, showgrid = FALSE   ,  tickfont=list(color="grey", size=15) , titlefont=list(color="grey", size=15) , tickcolor="grey" , linecolor="grey")
			)

		# Add vertical lines to represent chromosomes.
		for(m in c(1:nb_selected_maps)){
			p=add_trace(p, x=c(m,m), y=c(0, max(don[,m*2+1],na.rm=T)) , type="scatter", mode="lines" , line=list(width=4, color="black"),showlegend=F )%>%
			layout( yaxis=list(range=c(0,max(pos_final))) )
			}
		
		# Add markers
		for(m in c(1:nb_selected_maps)){
			obj2=don[,c(1,m*2+1)]
			obj2$text=paste(obj2[,1],"\npos: ",obj2[,2],sep="")
			p=add_trace(p, x=rep(m,nrow(obj2) ) , y=obj2[,2] , type="scatter", mode="markers+lines", marker=list(color="black" , size=10 , opacity=0.5,symbol=24) , text=obj2$text , hoverinfo="text", showlegend=F)%>%
			layout( yaxis=list(range=c(0,max(pos_final))) )
			}

		# Add maps names			
		p=add_trace(p, x=seq(1:nb_selected_maps) , y=rep(-10,nb_selected_maps) , text=unlist(liste_of_map_to_compare) , type="scatter" , mode="lines+text" , textfont=list(size=20 , color="orange"), line=list(color="transparent"), showlegend=F )

		#Draw the plot
		p
		

	
	})

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#








#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 4 : INTER CHROMOSOME ANALYSIS
#-----------------------------------------------------------------------------


  	output$plot2 <- renderPlotly({ 
  	
	 	# Get the needed reactive objects:
		summary_stat=MY_summary_stat()
		map_files=MY_map_files()
  		my_maps=MY_maps()
  		nb_de_carte=length(map_files)

 		# Avoid bug when loading
  		if (is.null(input$map1) | is.null(input$map2) | is.null(input$chromo_sheet4) ) {return(NULL)}

		# Get the first selected map
		selected=which(map_files%in%input$map1)
		map1=my_maps[[selected]]
		name1=map_files[selected]
		
		# Get the second selected map
		selected=which(map_files%in%input$map2)
		map2=my_maps[[selected]]
		name2=map_files[selected]

		# Select the choosen chromosome, the user can choose "all" !
		if(input$chromo_sheet4=="all"){map1=map1}else{map1=map1[map1[,1]==input$chromo_sheet4 , ]  ;  map2=map2[map2[,1]==input$chromo_sheet4 , ]}
				
		# a little function: I remake the x axis to add chromosomes beside each others.
		my_fun=function(a){
		last=0
		to_add=0
		out=c()
		for (i in a){
			if(i>=last) { sortie=i+to_add }
			if(i<last) {to_add=to_add+last+0.05*last ; sortie=i+to_add }
			last=i
			out=c(out,sortie)
			}
		return(out)
		}
		map1$pos_cum_map1=my_fun(map1[,3])
		map2$pos_cum_map2=my_fun(map2[,3])
		don=merge(map1,map2,by.x=2,by.y=2)
		
		#Calculation of max and min of every chromosome
		map1max=aggregate(don[,4] , by=list(don[,2]) , max)
		map1min=aggregate(don[,4] , by=list(don[,2]) , min)
		map2max=aggregate(don[,7] , by=list(don[,5]) , max)
		map2min=aggregate(don[,7] , by=list(don[,5]) , min)
		
		# --- Add a text column for plotly and compute some useful values for the plot drawing
		don$text=paste(don[,1],"\nmap1: position : ",round(don[,3],2)," | chromosome : ",don[,2],"\nmap2: position : ",round(don[,6],2)," | chromosome : ",don[,5],sep="")
		
		#Prepare 2 layouts !
		if(input$chromo_sheet4=="all"){
			lay_x=list(title = name1, tickmode="array", tickvals=map1max[,2] , ticktext="" , showticklabels = F )
			lay_y=list(title = name2, tickmode="array", tickvals=map2max[,2] , ticktext="" , showticklabels = F )
		}else{
			lay_x=list(title = name1 )
			lay_y=list(title = name2 )	
		}
		
		# Make the plot !
		p=plot_ly(don , x=don[,4] , y=don[,7] , mode="markers" , color=don[,2] , text=don$text , hoverinfo="text"  , marker=list( size=15 , opacity=0.5)  )
				
		# Add chromosome name on X and Y axis
		if(input$chromo_sheet4=="all")
		{
		retrait=ifelse(map1max[,2]>10000, -100 , -0.1*max(map1max[,2]) )
		p=add_trace(x=apply(cbind(map1max[,2],map1min[,2]) , 1 , mean) , y=rep(retrait,nrow(map1max)) , text=map1max[,1] , mode="text" , textfont=list(size=13 , color="orange") , showlegend=F)
		retrait=ifelse(map2max[,2]>10000, -100 , -0.1*max(map2max[,2]) )
		p=add_trace(x=rep(retrait,nrow(map2max)) , y=apply(cbind(map2max[,2],map2min[,2]) , 1 , mean) , text=map1max[,1] , mode="text" , textfont=list(size=13 , color="orange"), showlegend=F )
		}

		# Custom the layout
		p=layout( 
			#Gestion du hovermode
			hovermode="closest"  , xaxis=lay_x , yaxis=lay_y
		)
		p
		
  	#Je ferme le outputPlot2
  	})


  	output$key_numbers_sheet_3 <- renderPlot({ 
  	
	 	# Get the needed reactive objects:
		summary_stat=MY_summary_stat()
		map_files=MY_map_files()
  		my_maps=MY_maps()
  		nb_de_carte=length(map_files)

  		# Avoid bug when loading
  		if (is.null(input$map1) | is.null(input$map2) | is.null(input$chromo_sheet4) ) {return(NULL)}

		# Get the first selected map
		selected=which(map_files%in%input$map1)
		map1=my_maps[[selected]]
		name1=map_files[selected]
		
		# Get the second selected map
		selected=which(map_files%in%input$map2)
		map2=my_maps[[selected]]
		name2=map_files[selected]

		# Select the choosen chromosome, the user can choose "all" !
		if(input$chromo_sheet4=="all"){map1=map1}else{map1=map1[map1[,1]==input$chromo_sheet4 , ]  ;  map2=map2[map2[,1]==input$chromo_sheet4 , ]}
 		
 		# Compute basic statistics:
 		nb_mark_map1=nrow(map1)
 		nb_mark_map2=nrow(map2)
 		nb_common_mark=length(which(map1$marker%in%map2$marker))
 		tmp=merge(map1,map2,by.x=2,by.y=2)[c(3,5)]
 		coeff_cor=round(cor(tmp[,1] , tmp[,2] , method="spearman"),2)
 		
		# Then I make the "plot"
		par(bg="transparent" , mar=c(0,0,0,0) )
		plot(1,1,xaxt="n", yaxt="n",bty="n",xlab="",ylab="", col="transparent", xlim=c(0,4) , ylim=c(0.5,4.5) )
 		text(rep(1  ,4) , c(4,3,2,1) , c(nb_mark_map1, nb_mark_map2, nb_common_mark, coeff_cor),  col="orange" , cex=3 , adj=1 , font=2 )
		text(rep(1.2,4) , c(4,3,2,1) , c(paste("markers in\n",name1,sep=""), paste("markers in\n",name2,sep=""), "common\nmarkers","Spearman\ncorrelation") ,  col="grey" , cex=1.3 , font=2 , adj=0 )

 	#Je ferme le output avec un fond transparent
  	}, bg="transparent")
				

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#








#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 5 : ROUGH MAP VIZUALIZATION
#-----------------------------------------------------------------------------


		#Faire une réactive pour pouvoir faire le tableau désiré 
		observe({
		 	
			# Get the needed reactive objects:
			map_files=MY_map_files()
			my_maps=MY_maps()
	  	
  			# Avoid bug when loading
  			if (is.null(input$selected_maps_sheet5) ) {return(NULL)}
	
			#Get the selected map
			selected=which(map_files%in%input$selected_maps_sheet5)
			if(length(selected==1)){

				#Get the selected map
				data_for_map_table=my_maps[[selected]]
		
				#Get the selected chromosomes
				if(!("all"%in%input$chromo_sheet5)){
					selected_chromosomes=input$chromo_sheet5
					data_for_map_table=data_for_map_table[which(data_for_map_table[,1]%in%selected_chromosomes),]
					}

				#Close the if statement
				}		
			
				#Make the graph
				output$my_rough_map_viz <- renderDataTable(

					#See https://rstudio.github.io/DT/options.html for options in printing table
					data_for_map_table , escape = F , rownames = FALSE , options = list(pageLength = 40)
			
					#Close the output
					)

		#Close the observe
		})

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#



#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

	# Just 3 small tables for the documentation page
	a=c("marker_52", "marker_23", "marker_18", "marker_8", "marker_12", "marker_3", "marker_98", "marker_72")
	b=c(0.0,29.4,31.2,40.5,0.0,3.3,4.6,10.8)
	c=c(rep("LG1",4),rep("LG2",4))
	ex1=data.frame(LG=c , marker=a, position=b)
	output$doc_ex1 <- DT::renderDataTable(
		DT::datatable(ex1 , rownames = FALSE , options = list(dom = 't' ))
	)

	# Just 3 small tables for the documentation page
	a=c("group", "marker_52", "marker_23", "marker_18", "marker_8", "group", "marker_12", "marker_3", "marker_98", "marker_72")
	b=c("LG1",0.0,29.4,31.2,40.5,"LG2",0.0,3.3,4.6,10.8)
	ex2=data.frame(a , b)
	output$doc_ex2 <- DT::renderDataTable(
		DT::datatable(ex2 , rownames = FALSE , colnames="", options = list(dom = 't' ))
	)

	# Just 3 small tables for the documentation page
	ex3=data.frame("0 -801.56 {1 -485.24 MS4 0.0 MS5 3.3 MS13 38.8 MS6 64.2 MS11 86.4 MS17 137.9 MS16 159.5 MS8 186.5 MS7 192.4 MS2 207.4 MS3 208.0 MS9 231.5 MS15 249.3 MS12 252.8 MS20 291.1 MS19 293.8 MS1 483.9} {2 -316.32 MS4 0.0 MS5 84.4 MS6 138.5 MS8 229.0 MS7 307.2 MS3 493.5 MS9 706.1 MS15 862.8 MS1 1622.9 G36 1726.5 G39 1786.2 G37 1845.9 G40 1871.3}")
	output$doc_ex3 <- DT::renderDataTable(
		DT::datatable(ex3 , rownames = FALSE , colnames="", options = list(dom = 't' ))
	)

	
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#




#Je ferme le shinyServer
})









#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

