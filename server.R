
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













#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 2 : SUMMARY STATISTICS PAGE - BARPLOT !
#-----------------------------------------------------------------------------

	output$my_barplot=renderPlot({
	
		# Get the needed reactive objects:
		summary_stat=MY_summary_stat()
		map_files=MY_map_files()
	
  		# Avoid bug when loading
  		if (is.null(input$var_for_barplot) | is.null(input$selected_maps_sheet2) ) {return(NULL)}

		# Selected variable ?
		selected_var=which(c("nb. marker","size","average gap","biggest gap","Nb. uniq pos.")%in%input$var_for_barplot)

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
		mtext(legend[23] , col="#3C3C3C" , line=-3 , at=ncol(barplot_table)*nb_selected_maps+8)
		
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
		all_var=c("nb. marker","size","average gap","biggest gap","Nb. uniq pos.")
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
		print(barplot_table)
		doughnut(barplot_table, col=my_colors , border="white" , inner.radius=0.5, labels=my_labels )
		mtext(expression(italic(legend[24])) , col="#3C3C3C" , line=-5)
	
	#Close the render-barplot 
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
		
		# General graphical parameters
		par(mar =c(1, 1, 1, 1), lwd = 0.1, cex = 0.7)
		circos.par(track.height = 0.7/nb_de_carte)
		coul = brewer.pal(4, "Set3") 
		coul = colorRampPalette(coul)(nlevels(data_circ[,1]))
		num=0
		
		# Initialization of the circular plot
		circos.initialize(factors = data_circ[,1], x = data_circ$position)
		
		# Add chosen maps one by one
		for( i in c(1:nb_selected_maps)){
		
			# Select one of the chosen map
			don=data_circ[data_circ$map_name==levels(as.factor(data_circ$map_name))[i] , ]
					
			# add density curve
			circos.trackHist(don[,1], don$position, col="orange" , lwd=3 , draw.density=T, bg.col=coul)
					
			# add one black line for each marker
			circos.trackLines(don[,1], don$position, rep(0.005,nrow(don)), type = "h")
		
			}
		
		# add chromosome names
		for(i in levels(data_circ[,1])){
			circos.text(max(data_circ$position[data_circ[,1]==i])/2, 1.5, i, sector.index = i, track.index = 1 , col="orange" , cex=1.4 , lwd=2)
			}
			
		})
	
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#











#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 3 : MAP COMPARISON FOR A CHOSEN CHROMOSOME
#-----------------------------------------------------------------------------


	# liste_of_map_to_compare is an object with the genetic maps to compare, in the good order. I initialize it with the 2 first maps, like in the radiobutton.
	MY_liste_of_map_to_compare=reactive({
		map_files=MY_map_files()
		liste_of_map_to_compare=c(map_files[1],map_files[2])
		return(liste_of_map_to_compare)
		})
	old_choice=NULL
 
  
    output$plot1 <- renderPlotly({ 

		# Get the needed reactive objects:
		liste_of_map_to_compare=MY_liste_of_map_to_compare()
		summary_stat=MY_summary_stat()
		map_files=MY_map_files()
  		my_maps=MY_maps()
  		nb_de_carte=length(map_files)
    	data=MY_data()
   	

   		# --- Avoid bug when page is loading
  		if (is.null(input$selected_maps)) {return(NULL)}

  		# I get the current choice of maps to show:
		current_choice=reactive({ return(input$selected_maps) })

		# --- Avoid bug when less than 2 maps are selected
  		validate( need( length(current_choice())>1  , "Please select at least 2 maps"))
  		#if ( length(current_choice())<2 ) { plot_ly(x=1 , y=1)  }
  

		# --- First step : get the list of selected maps in the good order
		# Old_choice represents the last choice of the user (before the current one). I initialize it with the value of the 2 maps to compare
		if(is.null(old_choice)){ old_choice=liste_of_map_to_compare  }
		
		
		# If the user has added a map, I determine which, and add it to the map to compare:
		print("===the old choice was :")
		print(old_choice)
		
		if(length(current_choice()) > length(old_choice)){
			print("yes it is longer")
			to_add= current_choice()[-which(current_choice()%in%old_choice)]
			print("donc j'ajoute")
			print(to_add)
			print("à:")
			print(old_choice)

			liste_of_map_to_compare=c(old_choice,to_add)
			print("=================== list of map to compare:")
			print(liste_of_map_to_compare)
		}
		
		# If the user has removed a map, I determine which and remove it from the maps to compare:
		if(length(current_choice()) < length(old_choice)){
			print("yes it is SHORTER")
			to_del=old_choice[-which(old_choice%in%current_choice())]
			print("je dois supprimer")
			print(to_del)
			print("la liste acutelle c'est")
			print(old_choice)
			liste_of_map_to_compare=old_choice[ - which(old_choice%in%to_del) ]
			print("=================== list of map to compare:")
			print(liste_of_map_to_compare)
		}
					
		# To avoid a bug, when only ONE map is selected, the map to compare is this map:
		if(length(current_choice())==1){  liste_of_map_to_compare<<-current_choice() }
			
		# I save the current choice as old_choice for next change:
		old_choice<<-isolate(current_choice())


		# --- Make an input table with columns in the corresponding order: from mapB,mapA i keep column: 1, 4,5, 2,3:
		selected_maps=match(liste_of_map_to_compare , map_files)  
		selected_col=rep(selected_maps , each=2)*2
		selected_col=c(1,selected_col+rep(c(0,1) , length(selected_col)/2))
		dat=data[ , selected_col ]
		nb_selected_maps=length(selected_maps)
		 		
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
		p=plot_ly(x=xaxis , y=pos_final , hoverinfo="none" ,  line=list(width=0.4, color="purple" , opacity=0.1) , showlegend=F,  evaluate=TRUE)

		# Custom the layout
		p=layout( 
			#Gestion du hovermode
			hovermode="closest"  ,
			# Gestion des axes
			xaxis=list(title = "", zeroline = FALSE, showline = FALSE, showticklabels = FALSE, showgrid = FALSE , range=c(0.5,nb_selected_maps+0.5) ),
			yaxis=list(range=c(0,500), autorange = "reversed", title = "Position (cM)", zeroline = F, showline = T, showticklabels = T, showgrid = FALSE ,  tickfont=list(color="grey") , titlefont=list(color="grey") , tickcolor="grey" , linecolor="grey"),
			)

		# Add vertical lines to represent chromosomes
		for(m in c(1:nb_selected_maps)){
			p=add_trace( x=c(m,m), y=c(0, max(don[,m*2+1],na.rm=T)) , evaluate=TRUE , line=list(width=4, color="black") )
			p=layout( yaxis=list(range=c(0,max(pos_final))) )
			}
		
		# Add markers
		for(m in c(1:nb_selected_maps)){
			obj2=don[,c(1,m*2+1)]
			obj2$text=paste(obj2[,1],"\npos: ",obj2[,2],sep="")
			p=add_trace(obj2, x=rep(m,nrow(obj2) ) , y=obj2[,2] , mode="markers" ,  evaluate=TRUE, marker=list(color="black" , size=10 , opacity=0.5,symbol=24) , text=text , hoverinfo="text")
			p=layout( yaxis=list(range=c(0,max(pos_final))) )
			}

		# Add maps names			
		p=add_trace(x=seq(1:nb_selected_maps) , y=rep(-10,nb_selected_maps) , text=unlist(liste_of_map_to_compare) , mode="text" , textfont=list(size=20 , color="orange") )

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
		p=plot_ly(don , x=don[,4] , y=don[,7] , mode="markers" , color=don[,2] , text=don$text , hoverinfo="text"  , marker=list( size=15 , opacity=0.5)  , showlegend=F )
				
		# Add chromosome name on X and Y axis
		p=add_trace(x=apply(cbind(map1max[,2],map1min[,2]) , 1 , mean) , y=rep(-0.1*max(map1max[,2]),nrow(map1max)) , text=map1max[,1] , mode="text" , textfont=list(size=13 , color="orange") )
		p=add_trace(x=rep(-0.1*max(map2max[,2]),nrow(map2max)) , y=apply(cbind(map2max[,2],map2min[,2]) , 1 , mean) , text=map1max[,1] , mode="text" , textfont=list(size=13 , color="orange") )
		
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








#Je ferme le shinyServer
})

