
	#####################
	#
	#	DEVELOPPEMENT D'UNE APPLI SHINY POUR LA VISUALISATION DES QTLS MOSAIQUES ET FUSA
	#
	####################


# Libraries
library(shiny)
library(plotly)
library(DT)
library(circlize)
library(RColorBrewer)


# Colors for the App :
my_colors=brewer.pal( 12 , "Set3")[-2]








#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- UPLOAD MAPS AND FILE FORMATING
#-----------------------------------------------------------------------------

# --- Catch the map we have to compare :
map_files=list.files("DATA")
nb_de_carte=length(map_files)

# --- Load every maps and add their content in a list
my_maps=list(read.table(paste("DATA/",map_files[1],sep="") , header=T , dec="." ))
for(i in c(2:nb_de_carte)){
	my_maps[[length(my_maps)+1]]=read.table(paste("DATA/",map_files[i],sep="") , header=T , dec="." )
}
# If you want to see informations concerning the map number1 : nrow(my_maps[[1]])
# If you want the name of the map number one : print(args[i])

# --- Merge the maps together
data=merge(my_maps[[1]] , my_maps[[2]], by.x=2 , by.y=2 , all=T)
colnames(data)=c("marker",paste("chromo",map_files[1],sep="_") , paste("pos",map_files[1],sep="_") , paste("chromo",map_files[2],sep="_") , paste("pos",map_files[2],sep="_"))
if(nb_de_carte>2){
	for(i in c(3:nb_de_carte)){
		data=merge(data , my_maps[[i]] , by.x=1 , by.y=2 , all=T)
		colnames(data)[c( ncol(data)-1 , ncol(data) )]= c( paste("chromo",map_files[i],sep="_") , paste("pos",map_files[i],sep="_") )
	}}
# ---> I get a file summarizing the information for every markers present at least one time !


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#







#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- COMPUTE SUMMARY STATISTICS FOR EVERY MAPS
#-----------------------------------------------------------------------------

# Function 1 : give it a piece of map, it calculates some statistics and add it to a bilan data frame.
my_fun=function(my_map, bilan, i){
	num=nrow(bilan)
	num=num+1
	bilan[num,1]=i
	bilan[num,2]=nrow(my_map)
	bilan[num,3]=max(my_map[,3])
	gaps= sort(my_map[,3])[-1] - sort(my_map[,3])[-length(my_map[,3])] 
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

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#












# OPEN THE SHINY SERVER
shinyServer(function(input, output) {




#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

# --------------------------------------------------------------------------------
# 	CREATION OF THE DYNAMICS BUTTONS FOR THE UI SCRIPT
#--------------------------------------------------------------------------------

  # --- Dynamic UI for the MAP to study
  output$choose_maps<- renderUI({
  
    # Create the checkboxes and select the first one by default
    checkboxGroupInput("selected_maps", "Choose maps ! (from left to right)", choices=map_files, selected=c(map_files[1],map_files[2]) )
    
  })


  # --- Dynamic UI for the MAP to study
  output$choose_maps_sheet2<- renderUI({
  
    # Create the checkboxes and select the first one by default
    checkboxGroupInput("selected_maps_sheet2", "Choose maps !", choices=map_files, selected=c(map_files[1],map_files[2]) )
    
  })
  
  # --- Dynamic UI for the MAP to study
  output$choose_maps3<- renderUI({
  
    # Create the checkboxes and select the first one by default
    checkboxGroupInput("selected_maps", "Choose maps !", choices=map_files, selected=c(map_files[1],map_files[2]) )
    
  })

  # --- Dynamic UI for the MAP to study
  output$choose_maps4<- renderUI({
  
    # Create the checkboxes and select the first one by default
    radioButtons("selected_maps_sheet4", "Choose the reference map!", choices=map_files, selected=map_files[1] )
    
  })
  
  # --- Dynamic UI for the MAP to study
  output$map1<- renderUI({
  
    # Create the checkboxes and select the first one by default
    radioButtons("map1", "Choose a first map", choices=map_files, selected=map_files[1] )
    
  })

  # --- Dynamic UI for the MAP to study
  output$map2<- renderUI({
  
    # Create the checkboxes and select the first one by default
    radioButtons("map2", "Choose a second map", choices=map_files, selected=map_files[2] )
    
  })

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#









#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 1 : SUMMARY STATISTICS PAGE - BARPLOT !
#-----------------------------------------------------------------------------

	output$my_barplot=renderPlot({
	
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
		print(barplot_table)
		
		# Make the barplot !
		par(mar=c(3,3,3,8))
		barplot(barplot_table , beside=T , col=my_colors[1:length(selected_maps)]) 
		mtext(expression(italic("Fig. 2: Distribution of the requested \nfeature per maps.Values are given \nchromosome per chromosome")) , col="#3C3C3C" , line=-3 , at=ncol(barplot_table)*nb_selected_maps+8)

		
	#Close the render-barplot 
	})

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#






#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 1 : SUMMARY STATISTICS PAGE - PIEPLOT !
#-----------------------------------------------------------------------------

	output$my_pieplot=renderPlot({
	
		# Selected variable ?
		all_var=c("nb. marker","size","average gap","biggest gap","Nb. uniq pos.")
		selected_var=which(all_var%in%input$var_for_barplot)

		# Selected Maps ?
		selected_maps=which(map_files%in%input$selected_maps_sheet2)
		nb_selected_maps=length(selected_maps)
		print("ok")
		print(selected_maps)
		
		# Create a table which gives this selected_variable for every selected maps and every chromosomes.
		barplot_table=summary_stat[[selected_maps[1]]] [,c(1,selected_var+1)]
		for(i in selected_maps[-1]){
			barplot_table=merge(barplot_table , summary_stat[[i]] [,c(1,selected_var+1)] , by.x=1 , by.y=1 , all=T)
			}
		rownames(barplot_table)=barplot_table[,1]
		barplot_table=barplot_table[nrow(barplot_table) , ]
		barplot_table=t(as.matrix(barplot_table[,-1]))
		
		# Make the barplot !
		par(mar=c(3,3,3,10))
		my_colors=brewer.pal( 10 , "Set3")[1:length(selected_maps)]
		pie(barplot_table , col=my_colors , labels=paste(map_files[selected_maps],"\n",all_var[selected_var]," : ",barplot_table,sep="") )
		mtext(expression(italic("Fig. 1: Distribution of the requested \nfeature per maps.Calculations are \nmade considering the whole maps")) , col="#3C3C3C" , line=-5)
	#Close the render-barplot 
	})


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#





#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 1 : SUMMARY STATISTICS PAGE - CIRCULAR PLOT FOR DENSITY !
#-----------------------------------------------------------------------------

	# Make the circular plot. See https://cran.r-project.org/web/packages/circlize/vignettes/circlize.pdf to understand how circular plot works.
  	output$circular_plot <- renderPlot({ 
  	
		# Which maps have been selected ?
		selected_maps=which(map_files%in%input$selected_maps_sheet2)
		nb_selected_maps=length(selected_maps)
		
		# Fichier nécessaire
		data_circ=data.frame()
		for(i in selected_maps){
				current_map=my_maps[[i]]
				current_map$map_name=map_files[i] 
				current_map$group_and_name=paste(map_files[i] , current_map$group , sep="_")
				data_circ=rbind(data_circ , current_map)
			}
		
		# If the "all" option is not selected, then I keep only the chosen chromosomes
		if(!("all"%in%input$chromo_sheet2)){
			take=which(data_circ$group%in%input$chromo_sheet2)
			data_circ=data_circ[take , ]
			data_circ$group=droplevels(data_circ$group)
			}		
		
		# General graphical parameters
		par(mar =c(1, 1, 1, 1), lwd = 0.1, cex = 0.7)
		circos.par(track.height = 0.7/nb_de_carte)
		coul = brewer.pal(4, "Set3") 
		coul = colorRampPalette(coul)(nlevels(data_circ$group))
		num=0
		
		# Initialization of the circular plot
		circos.initialize(factors = data_circ$group, x = data_circ$position)
		
		# Add chosen maps one by one
		for( i in c(1:nb_selected_maps)){
		
			# Select one of the chosen map
			don=data_circ[data_circ$map_name==levels(as.factor(data_circ$map_name))[i] , ]
					
			# add density curve
			circos.trackHist(don$group, don$position, col="orange" , lwd=3 , draw.density=T, bg.col=coul)
					
			# add one black line for each marker
			circos.trackLines(don$group, don$position, rep(0.005,nrow(don)), type = "h")
		
			}
		
		# add chromosome names
		for(i in levels(data_circ$group)){
			circos.text(max(data_circ$position[data_circ$group==i])/2, 1.5, i, sector.index = i, track.index = 1 , col="orange" , cex=1.4 , lwd=2)
			}
			
		})
	
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#











#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 2 : MAP COMPARISON FOR A CHOSEN CHROMOSOME
#-----------------------------------------------------------------------------

	
  	output$plot1 <- renderPlotly({ 
  	
  	
		# Which maps have been selected ?
		selected_maps=which(map_files%in%input$selected_maps)
		selected_col=sort(c(1 , 2+(selected_maps-1)*2 , 3+(selected_maps-1)*2))
		dat=data[ , selected_col ]
		nb_selected_maps=length(selected_maps)
		
		# --- Subset of the dataset with only the good chromosome :
		don=dat[dat[,2]==input$chromo & !is.na(dat[,2]) , ]
		for(j in c(2:nb_selected_maps)){
			temp=dat[dat[,c((j-1)*2+2)]==input$chromo & !is.na(dat[,c((j-1)*2+2)]) , ]
			don=rbind(don,temp)
		}
		don=unique(don)


		# --- Change Matrix format :
		mat=data.frame(marker=don[,1] , carte=1 , position=don[ , 3])
		if(nb_selected_maps>1){
			for(i in c(2:nb_selected_maps)){
				to_add=data.frame(marker=don[,1] , carte=i , position=don[ , c((i-1)*2+3)])
				mat=rbind(mat,to_add)
		}}
		
		
		# --- Add a text column for plotly and compute some useful values for the plot drawing
		mat$text=paste(mat[,1],"\npos: ",round(mat[,3],2),sep="")
		my_ylim=max(mat$position, na.rm=T)
		
		print(head(mat))
		
		# --- Start the plotly graph
		p=plot_ly(mat , x=carte , y=position , text=text , hoverinfo="text" , mode="markers+lines"  , marker=list(color="black" , size=10 , opacity=0.5,symbol=24) , line=list(width=0.4, color="purple" , opacity=0.1) , showlegend=F  , group=marker)
		
		# Ajout d'un trait vertical pour chaque graph
		p=add_trace(x = c(1,1), y = c(0, my_ylim) , line=list(width=4, color="black"))
		if(nb_de_carte>2){p=add_trace(x = c(2,2), y = c(0, max(mat$position[mat$carte==2] , na.rm=T)) , line=list(width=4, color="black"))}
		if(nb_de_carte>2){p=add_trace(x = c(3,3), y = c(0, max(mat$position[mat$carte==3] , na.rm=T)) , line=list(width=4, color="black"))}
		if(nb_de_carte>3){p=add_trace(x = c(4,4), y = c(0, max(mat$position[mat$carte==4] , na.rm=T)) , line=list(width=4, color="black"))}
		if(nb_de_carte>4){p=add_trace(x = c(5,5), y = c(0, max(mat$position[mat$carte==5] , na.rm=T)) , line=list(width=4, color="black"))}
		if(nb_de_carte>5){p=add_trace(x = c(6,6), y = c(0, max(mat$position[mat$carte==6] , na.rm=T)) , line=list(width=4, color="black"))}
		if(nb_de_carte>6){p=add_trace(x = c(7,7), y = c(0, max(mat$position[mat$carte==7] , na.rm=T)) , line=list(width=4, color="black"))}
		
		# Ajout du nom des cartes
		p=add_trace(x=seq(1:nb_selected_maps) , y=rep(-10,nb_selected_maps) , text=unlist(input$selected_maps) , mode="text" , textfont=list(size=20 , color="orange") )
		
		# Custom the layout
		p=layout( 
			
			#Gestion du hovermode
			hovermode="closest"  ,
			
			# Gestion des axes
			xaxis=list(title = "", zeroline = FALSE, showline = FALSE, showticklabels = FALSE, showgrid = FALSE , range=c(0.5,nb_selected_maps+0.5) ),
			yaxis=list(autorange = "reversed", title = "Position (cM)", zeroline = F, showline = T, showticklabels = T, showgrid = FALSE ,  tickfont=list(color="grey") , titlefont=list(color="grey") , tickcolor="grey" , linecolor="grey"),
			
			)
		p
  	
  	#Je ferme le outpuPlot1
  	})
  	


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#


















#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 3 : INTER CHROMOSOME ANALYSIS
#-----------------------------------------------------------------------------


  	output$plot2 <- renderPlotly({ 

		# Get the first selected map & order it
		selected=which(map_files%in%input$map1)
		map1=my_maps[[selected]]
		map1=map1[order(map1[,1] , map1[,3] ) , ]
		name1=map_files[selected]
		
		# Get the second selected map
		selected=which(map_files%in%input$map2)
		map2=my_maps[[selected]]
		map2=map2[order(map2[,1] , map2[,3] ) , ]
		name2=map_files[selected]

		# Select the choosen chromosome, the user can choose "all" !
		if(input$chromo_sheet3=="all"){map1=map1}else{map1=map1[map1[,1]==input$chromo_sheet3 , ]  ;  map2=map2[map2[,1]==input$chromo_sheet3 , ]}
				
		# a little function
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
		if(input$chromo_sheet3=="all"){
			lay_x=list(title = name1, tickmode="array", tickvals=map1max[,2] , ticktext="" , showticklabels = F )
			lay_y=list(title = name2, tickmode="array", tickvals=map2max[,2] , ticktext="" , showticklabels = F )
		}else{
			lay_x=list(title = name1 )
			lay_y=list(title = name2 )	
		}
		
		# MAke the plot !
		p=plot_ly(don , x=don[,4] , y=don[,7] , mode="markers" , color=don[,2] , text=don$text , hoverinfo="text"  , marker=list( size=15 , opacity=0.5)  , showlegend=F )
		
		# Add one line per chromosome
		#p=add_trace(x = c(1,1), y = c(0, my_ylim) , line=list(width=4, color="black"))
		
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



#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#










#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 4 : ROUGH MAP VIZUALIZATION
#-----------------------------------------------------------------------------


		# TODO --> Fout le bordel sur sheet 2...


		#Faire une réactive pour pouvoir faire le tableau désiré 
		
		observe({
			
			#Get the selected map
			selected=which(map_files%in%input$selected_maps_sheet4)
			if(length(selected==1)){

				#Get the selected map
				data_for_map_table=my_maps[[selected]]
		
				#Get the selected chromosomes
				if(!("all"%in%input$chromo_sheet4)){
					selected_chromosomes=input$chromo_sheet4
					data_for_map_table=data_for_map_table[which(data_for_map_table$group%in%selected_chromosomes),]
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

