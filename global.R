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
  if(all(data%%1==0))
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
    data<-read.csv(file$datapath)
    if (check_file(data, name))
    {names(data)[1] <- name
    return(data)
    }
    return(NULL)
  }
}

exemplary_cdata<-read.csv("./Data/Ctrl_treat.txt")
exemplary_edata<-read.csv("./Data/Exp_treat.txt")

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


inf_file <- "The input file must be a txt file. It should consist of one column of RCB scores, not categories."
inf_name <- "Specify the name of the treatment. This will also update the name in the results and the plot."
exemp <- "Use the exemplary data to see the correct input files content."