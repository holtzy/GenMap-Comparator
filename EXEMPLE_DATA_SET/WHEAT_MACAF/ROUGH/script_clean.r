args <- commandArgs(trailingOnly = TRUE)


data=read.table(args[1] , sep="\t" , header=T)
data$real=substr(data[,1] , 1 , 2)


save_real=0
save_fake=0

for(i in c(1:nrow(data))){

	# Si je change de chromosome vrai:
	if(data[i,4] != save_real) { save_real=data[i,4] ; save_fake=data[i,1] ; print(save_real) ; to_add=0 }

	# Si je change de chromosome faux:
	if(data[i,1] != save_fake) { 
		
		# du coup a partir de mainntan j'ajouterai la valeur du dernier marqueur:
		to_add=save_pos
		
		# Et je remet a jour save_fake
		save_fake=data[i,1]
		}
	
	# A chaque fois j'ajoute la quantité necessaire
	data[i,3]=data[i,3]+to_add
	
	#Et je sauvegarde la position du marqueur actuel, ca servira
	save_pos=data[i,3]

}

data=data[,c(4,2,3)]

write.table(data , file=args[2] , sep="\t" , quote=F , row.names=F)
