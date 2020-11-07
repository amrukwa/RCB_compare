library(ggplot2)
library(tools)
library(shinythemes)
library(shinyalert)

server <- function(input, output, session) {
  v <- reactiveValues(used_cdata=NULL, used_edata=NULL, gen=NULL)
  cdata <- reactive({handle_file(input$control_file, input$control_name)})
  edata <- reactive({handle_file(input$exp_file, input$exp_name)})
  observeEvent(input$generate_plot, v$used_edata <- ({
    if(!input$exemplary_files){edata()}
    else
    {load_exemplary("experimental", input$exp_name)}
  }))
  observeEvent(input$generate_plot, v$used_cdata <- ({
    if(!input$exemplary_files){cdata()}
    else
    {load_exemplary("control", input$control_name)}
  }))
  observeEvent(input$generate_plot, v$gen <- qplot(v$used_cdata$control, geom="histogram") )
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
    v$gen})
  
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