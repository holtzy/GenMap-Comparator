
	#####################
	#
	#	DEVELOPPEMENT D'UNE APPLI SHINY POUR LA VISUALISATION DES QTLS MOSAIQUES ET FUSA
	#
	####################


# Libraries
library(shiny)
library(plotly)




#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- FILE FORMATING
#-----------------------------------------------------------------------------

# --- Catch the map we have to compare :
map_files=list.files("../DATA")
nb_de_carte=length(map_files)
print(nb_de_carte)


# --- Je charge les n cartes dans une liste Et je fais une liste de toutes mes cartes
my_maps=list(read.table(paste("../DATA/",map_files[1],sep="") , header=T , dec="." ))
for(i in c(2:nb_de_carte)){
	my_maps[[length(my_maps)+1]]=read.table(paste("../DATA/",map_files[i],sep="") , header=T , dec="." )
}
# Donc si je veux des infos sur ma premiere carte je fais par example : nrow(my_maps[[1]])
# Et si je veux le nom de ma premiere carte : print(args[i])

# --- Merge the maps together
data=merge(my_maps[[1]] , my_maps[[2]], by.x=2 , by.y=2 , all=T)
colnames(data)=c("marker",paste("chromo",map_files[1],sep="_") , paste("pos",map_files[1],sep="_") , paste("chromo",map_files[2],sep="_") , paste("pos",map_files[2],sep="_"))
if(nb_de_carte>2){
	for(i in c(3:nb_de_carte)){
		data=merge(data , my_maps[[i]] , by.x=1 , by.y=2 , all=T)
		colnames(data)[c( ncol(data)-1 , ncol(data) )]= c( paste("chromo",map_files[i],sep="_") , paste("pos",map_files[i],sep="_") )
	}}

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#





#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- A FUNCTION THAT DOES A GRAPH FROM THE DATASET
#-----------------------------------------------------------------------------


# --- Création d'une fonction qui a partir d'une partie de data fait le graph
my_function=function(data , nb_de_carte , chromo){
	
	#Initialiation de la carte
	par(mar=c(2,4,1,1))
	my_ylim=max(data[ , c(seq(3,ncol(data),2))] , na.rm=T) + 10
	plot(c(1:nb_de_carte) , data[1 , c(seq(3,ncol(data),2))] , type="l" , ylim=rev(c(-1,my_ylim)) , xlab="" , col=rgb(0.3,0.4,0.8,0.4) , axes=F , ylab="position en cM" , col.lab="grey" , xlim=c(0.75,nb_de_carte+0.25) )			
	axis(2 , las=2 , col="grey" , col.axis="grey"  )
	
	#J'ajoute un trait par carte
	for(i in c(1:nb_de_carte)){
		segments(i,0,i,max(data[,c((i-1)*2+3)],na.rm=T) , lwd=4)
		}
		
	#J'ajoute un trait par marqueur sur le chromosome
	for(i in c(1:nb_de_carte)){
		for(j in c(1:nrow(data))){
			segments(i-0.02 , data[j,c((i-1)*2+3)] , i+0.02 , data[j,c((i-1)*2+3)] )
		}}

	#Je relie les marqueurs communs
	for( i in c(2:nrow(data))){
		points(c(1:nb_de_carte) , data[i , c(seq(3,ncol(data),2)) ] , type="l" , col=rgb(0.3,0.4,0.8,0.4) )
		}

	#J'ajoute le nom des carte en dessous :
	for(i in c(1:nb_de_carte)){
		text(i,my_ylim+2,map_files[i] , col="orange" )
		}
		
	# J'ajoute le nom du chromosome + le nombre de marqueur
	nb_mark=
	text(ifelse(nb_de_carte==2,0.9,0.7) ,-4,chromo, col="orange" )

	}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#








#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------
# --- RUN THE FUNCTION WITH THE CHOSE CHROMOSOME
#-----------------------------------------------------------------------------





shinyServer(function(input, output) {


	
  	output$plot1 <- renderPlotly({ 
  	
  	
		# --- Subset of the dataset with only the good chromosome :
		don=data[data[,2]==input$chromo & !is.na(data[,2]) , ]
		for(j in c(2:nb_de_carte)){
			temp=data[data[,c((j-1)*2+2)]==input$chromo & !is.na(data[,c((j-1)*2+2)]) , ]
			don=rbind(don,temp)
		}
		don=unique(don)


		# --- Change Matrix format :
		mat=data.frame(marker=don[,1] , carte=1 , position=don[ , 3])
		for(i in c(2:nb_de_carte)){
			print(i)
			to_add=data.frame(marker=don[,1] , carte=i , position=don[ , c((i-1)*2+3)])
			mat=rbind(mat,to_add)
			print(summary(mat))
		}
		
		
		# --- Add a text column for plotly and compute some useful values for the plot drawing
		mat$text=paste(mat[,1],"\npos: ",round(mat[,3],2),sep="")
		my_ylim=max(mat$position, na.rm=T)



		# --- Start the plotly graph
		p=plot_ly(mat , x=carte , y=position , text=text , hoverinfo="text" , mode="markers+lines" , group=marker , marker=list(color="black" , size=10 , opacity=0.5,symbol=24) , line=list(width=0.4, color="purple" , opacity=0.1) , showlegend=F , evaluation = FALSE )
		
		# Ajout d'un trait vertical pour chaque graph
		p=add_trace(x = c(1,1), y = c(0, my_ylim) , line=list(width=4, color="black"))
		if(nb_de_carte>2){p=add_trace(x = c(2,2), y = c(0, max(mat$position[mat$carte==2] , na.rm=T)) , line=list(width=4, color="black"))}
		if(nb_de_carte>2){p=add_trace(x = c(3,3), y = c(0, max(mat$position[mat$carte==3] , na.rm=T)) , line=list(width=4, color="black"))}
		if(nb_de_carte>3){p=add_trace(x = c(4,4), y = c(0, max(mat$position[mat$carte==4] , na.rm=T)) , line=list(width=4, color="black"))}
		if(nb_de_carte>4){p=add_trace(x = c(5,5), y = c(0, max(mat$position[mat$carte==5] , na.rm=T)) , line=list(width=4, color="black"))}
		if(nb_de_carte>5){p=add_trace(x = c(6,6), y = c(0, max(mat$position[mat$carte==6] , na.rm=T)) , line=list(width=4, color="black"))}
		if(nb_de_carte>6){p=add_trace(x = c(7,7), y = c(0, max(mat$position[mat$carte==7] , na.rm=T)) , line=list(width=4, color="black"))}
		
		# Ajout du nom des cartes
		p=add_trace(x=seq(1:nb_de_carte) , y=rep(-10,nb_de_carte) , text=unlist(map_files) , mode="text" , textfont=list(size=30 , color="orange") )
		
		# Custom the layout
		p=layout( 
			
			#Gestion du hovermode
			hovermode="closest"  ,
			
			# Gestion des axes
			xaxis=list(title = "", zeroline = FALSE, showline = FALSE, showticklabels = FALSE, showgrid = FALSE , range=c(0.5,nb_de_carte+0.5) ),
			yaxis=list(autorange = "reversed", title = "Position (cM)", zeroline = F, showline = T, showticklabels = T, showgrid = FALSE ,  tickfont=list(color="grey") , titlefont=list(color="grey") , tickcolor="grey" , linecolor="grey"),
			
			)
p

  	
  	#Je ferme le outpuPlot1
  	})
  	
  	
#Je ferme le shinyServer
})

