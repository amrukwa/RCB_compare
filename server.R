library(ggplot2)
library(tools)
library(shinythemes)
library(shinyalert)
source('Calculate_TES.R')

server <- function(input, output, session) {
  v <- reactiveValues(gen=NULL, res_TES=NULL, calc=NULL)
  tables <- reactiveValues(used_cdata=NULL, used_edata=NULL)
  cdata <- reactive({handle_file(input$control_file, input$control_name)})
  edata <- reactive({handle_file(input$exp_file, input$exp_name)})
  observeEvent(input$generate_plot, {
    tables$used_edata <- load_data(input$exemplary_files, edata(),input$exp_name, "experimental")
    tables$used_cdata <- load_data(input$exemplary_files, cdata(),input$control_name, "control")
    if(is.null(tables$used_cdata) | is.null(tables$used_edata) ){
      v$calc = NULL}
    })
  erow <- reactive({nrow(tables$used_edata)})
  crow <- reactive({nrow(tables$used_cdata)})
  observeEvent(c(tables$used_edata, tables$used_cdata), 
               {
                 validate(need(tables$used_edata, ''), need(tables$used_cdata, ''))
                 v$calc = TRUE
                 if(erow()==crow()) {if(all(tables$used_cdata==tables$used_edata)) {shinyalert("Warning","Uploaded files have the same content",
                                                                                     type="warning")}}
               })
  output$ccontents <- renderTable({tables$used_cdata})
  output$econtents <- renderTable({tables$used_edata})
  output$ncontrol <- renderText({crow()})
  output$nexp <- renderText({erow()})
  observeEvent(v$calc, {
    v$res_TES <- calculate_TES(input$method, tables$used_cdata, tables$used_edata)
    v$gen <- grid.arrange(v$res_TES[["Plot1"]],v$res_TES[["Plot2"]],nrow=2)} )
  
  output$nexp1 <- renderPlot({
    validate(need(v$res_TES, " "))
    grid.arrange(v$res_TES[["Plot1"]],v$res_TES[["Plot2"]],nrow=2)})
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("plot", Sys.Date(), ".pdf", sep="")
    },
    content = function(file) {
      ggsave(v$gen, filename = file)
    }
    )
  observeEvent(v$res_TES, {
    if (is.null(tables$used_edata) || is.null(tables$used_cdata))
      shinyjs::hide("downloadData")
    else
      shinyjs::show("downloadData")
  })
}