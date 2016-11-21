
		################################################
		#
		#		THE GENETIC MAP COMPARATOR
		#
		###############################################



# ---- PART1 : Check that the currently-installed version of R is at least the minimum required version.
R_min_version = "3.1"
R_version = paste0(R.Version()$major, ".", R.Version()$minor)
if(compareVersion(R_version, R_min_version) < 0){
  stop("You do not have the latest required version of R installed.\n", 
       "Launch should fail.\n",
       "Go to http://cran.r-project.org/ and update your version of R.")
}



# ----- PART2: Install basic required packages if not available/installed.
install_missing_packages = function(pkg, version = NULL, verbose = TRUE){
  availpacks = .packages(all.available = TRUE)
  #source("http://bioconductor.org/biocLite.R")
  missingPackage = FALSE
  if(!any(pkg %in% availpacks)){
    if(verbose){
      message("The following package is missing.\n",
              pkg, "\n",
              "Installation will be attempted...")
    }
    missingPackage <- TRUE
  }
  if(!is.null(version) & !missingPackage){
    # version provided and package not missing, so compare.
    if( compareVersion(a = as.character(packageVersion(pkg)),
                       b = version) < 0 ){
      if(verbose){
        message("Current version of package\n", 
                pkg, "\t", 
                packageVersion(pkg), "\n",
                "is less than required.
                Update will be attempted.")
      }
      missingPackage <- TRUE
    }
  }
  if(missingPackage){
    #biocLite(i, suppressUpdates = TRUE)
    print(pkg)
    print(paste("---- installing a more recent version of",pkg,sep=""))
	install.packages(pkg, repos = "http://cran.r-project.org")  }
}


# PART3: ---  Define list of package names and required versions.
deppkgs = c(shiny="0.14.2", plotly = "4.5.6", ggplot2 = "2.2.0", DT="0.2", shinythemes="1.1", shinyAce="0.2.1", RColorBrewer="1.1.2", qualV="0.3.2", colourpicker="0.2")

# Loop on package check, install, update
pkg1 = mapply(install_missing_packages,
              pkg = names(deppkgs), 
              version = deppkgs,
              MoreArgs = list(verbose = TRUE), 
              SIMPLIFY = FALSE,
              USE.NAMES = TRUE)
              


################################################################################
# Load packages that must be fully-loaded 
################################################################################
for(i in names(deppkgs)){
  library(i, character.only = TRUE)
  message(i, " package version:\n", packageVersion(i))
}
################################################################################

# In this file, I add all functions / file / parameters that are NOT reactive and that are common to ui.R and server.R
# It is my global environment !


# == Check if libraries are available. install it if not.
#getPckg <- function(pckg) install.packages(pckg, repos = "http://cran.r-project.org")
#for(i in c("shiny","plotly","DT","RColorBrewer","shinyAce","shinythemes","qualV")){
#	pckg = try(require(i, character.only = TRUE))
#	if(!pckg) {
#		getPckg(i)
#}}


# == load Libraries
#library(shiny)
#library(plotly)
#library(DT)
#library(RColorBrewer)
#library(shinyAce) 
#library(shinythemes) 
#library(qualV)
		
# == Colors for the App :
my_colors=brewer.pal( 12 , "Set3")[-2]

# == Get the legends
legend1=read.table("LEGEND/legend_sheet1.txt",sep="@")[,2]
legend2=read.table("LEGEND/legend_sheet2.txt",sep="@")[,2]
legend3=read.table("LEGEND/legend_sheet3.txt",sep="@")[,2]
legend4=read.table("LEGEND/legend_sheet4.txt",sep="@")[,2]
legend5=read.table("LEGEND/legend_sheet5.txt",sep="@")[,2]
legend6=read.table("LEGEND/legend_sheet6.txt",sep="@")[,2]

# == Functions
# Donut plot
source("RESSOURCES/donut_function.R")

# == Set the size of the logo of partners
grand=1.5

