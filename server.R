library(ggplot2)
library(tools)
library(shinythemes)
library(shinyalert)

server <- function(input, output, session) {
  v <- reactiveValues(used_cdata=NULL, used_edata=NULL, gen=NULL)
  cdata <- reactive({handle_file(input$control_file, input$control_name)})
  edata <- reactive({handle_file(input$exp_file, input$exp_name)})
  observeEvent(input$up_df, v$used_edata <- ({
    if(!input$exemplary_files){edata()}
    else
    {load_exemplary("experimental", input$exp_name)}
  }))
  observeEvent(input$up_df, v$used_cdata <- ({
    if(!input$exemplary_files){cdata()}
    else
    {load_exemplary("control", input$control_name)}
  }))
  observeEvent(input$generate_plot, v$gen <- names(v$used_cdata)[1])
  erow <- reactive({nrow(v$used_edata)})
  crow <- reactive({nrow(v$used_cdata)})
  observeEvent(c(v$used_edata, v$used_cdata), 
               {
                 validate(need(v$used_edata, ''), need(v$used_cdata, ''))
                 if(all(v$used_cdata==v$used_edata)) {shinyalert("Warning","Uploaded files have the same content",
                                                                 type="warning")}
                 if(erow()!=crow()) {shinyalert("Warning","Uploaded files have different lengths",
                                                type="warning")}
               },
               ignoreInit = TRUE)
  
  output$ccontents <- renderTable({v$used_cdata})
  output$econtents <- renderTable({v$used_edata})
  output$ncontrol <- renderText({crow()})
  output$nexp <- renderText({erow()})
  output$nexp1 <- renderText({
    validate(
      need(global$datapath, "Choose the directory to save the results."),
      need(v$used_edata, 'Choose correct experimental treatment file.'),
      need(v$used_cdata, 'Choose correct control treatment file.'),
      need(input$generate_plot, "Click 'calculate' after updating files.")
    )
    v$gen})
  
  shinyDirChoose(
    input,
    'dir',
    roots = c(wd = 'C:'),
    filetypes = c(''))
  
  global <- reactiveValues(datapath = NULL)
  dir <- reactive(input$dir)
  output$dir <- renderText({
    global$datapath
  })
  
  observeEvent(ignoreNULL = TRUE,
               eventExpr = {input$dir},
               handlerExpr = {
                 if (!"path" %in% names(dir())) return()
                 home <- normalizePath("~")
                 global$datapath <-
                   file.path(home, paste(unlist(dir()$path[-1]), collapse = .Platform$file.sep))
               })
  
}