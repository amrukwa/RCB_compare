tmp <- sapply(paste0("./Rscripts/",list.files(path="Rscripts")), source)
my_packages <- c("ggplot2","densratio","parallel","reshape","pcg","gridExtra", "shiny", "tools", "shinythemes", "shinyalert", "shinyjs", "shinycssloaders")
lapply(my_packages, require, character.only = TRUE)

plot_theme <- theme(plot.background = element_rect(fill=alpha('#2F3635', 0.1), colour=alpha('#2F3635', 0.05)),
                    panel.background = element_rect(fill=alpha('#2F3635', 0.04), colour=alpha('#2F3635', 0.02)),
                    panel.grid.major = element_line(colour=alpha('#2F3635', 0.1)), 
                    panel.grid.minor = element_line(colour=alpha('#2F3635', 0.1)),
                    legend.background=element_rect(fill=alpha('#2F3635', 0.02), colour=alpha('#2F3635', 0.01)))
check_file <- function(data, name)
{
  is_correct = TRUE
  if(ncol(data)!=1)
  {
    shinyalert("Column Error", paste("Uploaded data -", name, "- doesn't have 1 column"),type="error")
    is_correct = FALSE
  }
  if(is.character(unlist(data)))
  {
    shinyalert("Type Error", paste("Uploaded data -", name, "- includes characters"),type="error")
    return(FALSE)
  }
  if(all(data%%1==0) && any(data!=0))
  {
    shinyalert("Type Error", paste("Uploaded data -", name, "- includes only integers"),type="error")
    is_correct = FALSE
  }
  if(any(data > 10))
  {
    shinyalert("Type Error", paste("Uploaded data -", name, "- includes numbers bigger than 10"),type="error")
    is_correct = FALSE
  }
  if(any(data < 0))
  {
    shinyalert("Type Error", paste("Uploaded data -", name, "- includes negative numbers"),type="error")
    is_correct = FALSE
  }
  return(is_correct)
}

handle_file <-function(file, name)
{
  if(is.null(file)) {returnValue()}
  else
  {
    data<-read.csv(file$datapath, header = FALSE)
    if (check_file(data, name))
    {names(data)[1] <- name
    return(data)
    }
    return(NULL)
  }
}

exemplary_cdata<-read.csv("./Data/Ctrl_treat.txt", header = FALSE)
exemplary_edata<-read.csv("./Data/Exp_treat.txt", header = FALSE)

load_exemplary <- function(example_type, name)
{
  if (example_type=="control")
  {
    data<-exemplary_cdata
    names(data)[1] <- name
    return(data)
  }
  else 
  {
    data<-exemplary_edata
    names(data)[1] <- name
    return(data)
  }
}

load_data <- function(is_exemplary, file, name=NULL, example_type = NULL)
{
  if(!is_exemplary){
    file
  }else{
      load_exemplary(example_type, name)
  }
}

inf_file <- "The input file must be a txt file. It should consist of one column of continuous RCB scores, not categories."
inf_name <- "Specify the name of the treatment. This will also update the name in the results and the plot."
exemp <- "Use the exemplary data to see the correct input files content."

sidebarPanel2 <- function (..., out = NULL, width=4) 
{
  div(class = paste0("col-sm-", width), 
      tags$form(class = "well", ...),
      out
  )
}