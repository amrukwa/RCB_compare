library(ggplot2)
library(tools)
library(shinythemes)
library(shinyalert)
source('Calculate_TES.R')

server <- function(input, output, session) {
  v <- reactiveValues(used_cdata=NULL, used_edata=NULL, gen=NULL, res_TES=NULL)
  cdata <- reactive({handle_file(input$control_file, input$control_name)})
  edata <- reactive({handle_file(input$exp_file, input$exp_name)})
  observeEvent(input$generate_plot, {
    v$used_edata <- load_data(input$exemplary_files, edata(), "experimental",input$exp_name)
    v$used_cdata <- load_data(input$exemplary_files, cdata(), "control",input$control_name)
    })
  observeEvent(input$generate_plot, { v$res_TES <- calculate_TES(input$method, v$used_cdata, v$used_edata)
    v$gen <- grid.arrange(v$res_TES[["Plot1"]],v$res_TES[["Plot2"]],nrow=2)} )
  erow <- reactive({nrow(v$used_edata)})
  crow <- reactive({nrow(v$used_cdata)})
  observeEvent(c(v$used_edata, v$used_cdata), 
               {
                 validate(need(v$used_edata, ''), need(v$used_cdata, ''))
                 if(erow()==crow()) {if(all(v$used_cdata==v$used_edata)) {shinyalert("Warning","Uploaded files have the same content",
                                                                                     type="warning")}}
               })
  
  output$ccontents <- renderTable({v$used_cdata})
  output$econtents <- renderTable({v$used_edata})
  output$ncontrol <- renderText({crow()})
  output$nexp <- renderText({erow()})
  output$nexp1 <- renderPlot({
    validate(
      need(v$used_edata, 'Choose correct experimental treatment file.'),
      need(v$used_cdata, 'Choose correct control treatment file.'),
      need(input$generate_plot, "Click 'calculate' after updating files.")
    )
    grid.arrange(v$res_TES[["Plot1"]],v$res_TES[["Plot2"]],nrow=2)})
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("plot", Sys.Date(), ".pdf", sep="")
    },
    content = function(file) {
      ggsave(v$gen, filename = file)
    }
    )
  observeEvent(input$generate_plot, {
    if (is.null(v$used_edata) || is.null(v$used_cdata))
      shinyjs::hide("downloadData")
    else
      shinyjs::show("downloadData")
  })
}