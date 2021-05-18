tmp <- sapply(paste0("./Rscripts/",list.files(path="Rscripts")), source)
my_packages <- c("ggplot2","densratio","parallel","reshape","pcg","gridExtra", 
                 "shiny", "shinyWidgets", "tools", "shinythemes", "shinyalert", "shinyjs", "shinycssloaders",
                 "promises", "future", "ipc")
lapply(my_packages, require, character.only = TRUE)

# use with pills in tabs
css <- HTML("h4 {
  color:black;
            }
            
            body {
            background-color: #fff;
            }
            
            a {color: black;}
            a:hover{
            color:black;}
            .tabbable > .nav > li > a                  {color:white;}
            .tabbable > .nav > li[class=active]    > a {color:white;}
            ")

plot_theme <- theme(
                    panel.grid.major = element_line(size = 1.25), 
                    panel.grid.minor = element_line(size=1.25),
                    text = element_text(size=15)
  )
  
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

sidebarPanel2 <- function (..., width=4, style = "position:fixed;width:inherit;") 
{
  div(class = paste0("col-sm-", width), 
      tags$form(class = "well", ...),
      tags$div(
        tags$span(style = "color: black;", includeHTML("www/include.html")))
  )
}