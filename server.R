

		################################################
		#
		#		THE GENETIC MAP COMPARATOR
		#
		###############################################


# Libraries
library(shiny)
library(plotly)
library(DT)
library(circlize)
library(RColorBrewer)

# Colors for the App :
my_colors=brewer.pal( 12 , "Set3")[-2]

#Get the legends
legend=read.table("LEGEND/all_legend.txt",sep="@")[,2]







#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- UPLOAD MAPS AND FILE FORMATING
#-----------------------------------------------------------------------------

# --- Catch the map we have to compare :
map_files=list.files("DATA")
nb_de_carte=length(map_files)



# --- Load every maps and add their content in a list. (I keep only the first 3 columns, and I order the maps by LG and positions)
my_maps=list()
for(i in c(1:nb_de_carte)){
	map_tmp=read.table(paste("DATA/",map_files[i],sep="") , header=T , dec="." ,na.strings="NA")[,c(1:3)]
	map_tmp=map_tmp[order(map_tmp[,1] , map_tmp[,3] ) , ]
	my_maps[[length(my_maps)+1]]=map_tmp
}
head(my_maps)
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
# I have now a file summarizing the information for every markers present at least one time !


# --- Get a list with the existing chromosomes:
chromosome_list=unlist(data[ , seq(2,ncol(data),2) ])
chromosome_list=as.character(unique(sort( chromosome_list[!is.na(chromosome_list)] )))

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


  # ======== sheet2: Summary Statistics =========
  # MAP to study
  output$choose_maps_sheet2<- renderUI({ checkboxGroupInput("selected_maps_sheet2", "Choose maps !", choices=map_files, selected=c(map_files[1],map_files[2]) ) })
  # Chromosomes to study
  output$choose_chromo_sheet2<- renderUI({checkboxGroupInput( "chromo_sheet2", legend[5], choices=chromosome_list , selected =c(chromosome_list[1],chromosome_list[2]) , inline = TRUE ) })


  # ======== sheet3: Compare Positions =========
  # Map to study
  output$choose_maps3<- renderUI({ checkboxGroupInput("selected_maps", "Choose maps !", choices=map_files, selected=c(map_files[1],map_files[2]) ) })
  # Chromosomes to study
  output$choose_chromo_sheet3<- renderUI({selectInput( "chromo", legend[5], choices=chromosome_list , selected =c(chromosome_list[1],chromosome_list[2]) ) })


  # ======== sheet4: Interchromosomal Analyse =========
  # First map to study :
  output$map1<- renderUI({ radioButtons("map1", "Choose a first map", choices=map_files, selected=map_files[1] ) })
  # Second map to study :
  output$map2<- renderUI({ radioButtons("map2", "Choose a second map", choices=map_files, selected=map_files[2] ) })
  # Chromosomes to study
  output$choose_chromo_sheet4<- renderUI({   selectInput( "chromo_sheet4", legend[10], choices=c("all", chromosome_list) , selected =c("all") )  })


  # ======== sheet5: Rough Map vizualisation =========
  # MAP to study
  output$choose_maps5<- renderUI({ radioButtons("selected_maps_sheet5", "Choose the reference map!", choices=map_files, selected=map_files[1] ) })
  # Chromosomes to study
  output$choose_chromo_sheet5<- renderUI({   checkboxGroupInput( "chromo_sheet5", legend[13], choices=c("all", chromosome_list) , selected =c(chromosome_list[1],chromosome_list[2]) , inline = TRUE )     })
  


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#












#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 2 : SUMMARY STATISTICS PAGE - BARPLOT !
#-----------------------------------------------------------------------------

	output$my_barplot=renderPlot({
	
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
# --- SHEET 2 : SUMMARY STATISTICS PAGE - PIEPLOT !
#-----------------------------------------------------------------------------

	output$my_pieplot=renderPlot({
	
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
		
		# Make the barplot !
		par(mar=c(3,3,3,10))
		pie(barplot_table , col=my_colors , labels=paste(map_files[selected_maps],"\n",all_var[selected_var]," : ",barplot_table,sep="") )
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
# --- SHEET 3 : MAP COMPARISON FOR A CHOSEN CHROMOSOME
#-----------------------------------------------------------------------------

	

	# liste_of_map_to_compare is an object with the genetic maps to compare, in the good order. I initialize it with the 2 first maps, like in the radiobutton.
	liste_of_map_to_compare=c(map_files[1],map_files[2])
	old_choice=NULL
 	
  	output$plot1 <- renderPlotly({ 
  	

  	
  		# --- Avoid bug when page is loading
  		if (is.null(input$selected_maps)) {return(NULL)}
  		
		# --- First step : get the list of selected maps in the good order
		# Old_choice represents the last choice of the user (before the current one). I initialize it with the value of the 2 maps to compare
		if(is.null(old_choice)){ old_choice=liste_of_map_to_compare  }
		
		# I get the current choice :
		current_choice=reactive({ input$selected_maps })
		
		# If the user has added a map, I determine which, and add it to the map to compare:
		if(length(current_choice()) > length(old_choice)){
			to_add= current_choice()[-which(current_choice()%in%old_choice)]
			liste_of_map_to_compare<<-c(liste_of_map_to_compare,to_add)
			}
		
		# If the user has removed a map, I determine which and remove it from the maps to compare:
		if(length(current_choice()) < length(old_choice)){
			to_del=old_choice[-which(old_choice%in%current_choice())]
			liste_of_map_to_compare<<-liste_of_map_to_compare[ - which(liste_of_map_to_compare%in%to_del) ]
			}
					
		# To avoid a bug, when only ONE map is selected, the map to compare is this map:
		if(length(current_choice())==1){print("exception!") ;  liste_of_map_to_compare<<-current_choice() }
			
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
			correctif=seq(1:length(my_vect)) + rep(c(0,0,1,-1) , length(my_vect)/4)
			my_vect=my_vect[correctif]
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

  	
  	# Close outputPlot1
  	})
  	

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#


















#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- SHEET 4 : INTER CHROMOSOME ANALYSIS
#-----------------------------------------------------------------------------


  	output$plot2 <- renderPlotly({ 
  	
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


  	output$key_numbers_sheet_3 <- renderPlot({ 
  	
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

