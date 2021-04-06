source('Calculate_TES.R')

server <- function(input, output, session) {
  # prepare reactive values
  v <- reactiveValues(gen=NULL, res_TES=NULL, method=NULL, to_save=NULL, caption=NULL)
  tables <- reactiveValues(used_cdata=NULL, used_edata=NULL)
  # load the user files
  cdata <- reactive({handle_file(input$control_file, input$control_name)})
  edata <- reactive({handle_file(input$exp_file, input$exp_name)})
  # load the specified files - be it the user files already prepared or the exemplary
  observeEvent(input$generate_plot, {
    v$method <- input$method
    tables$used_edata <- load_data(input$exemplary_files, edata(),input$exp_name, "experimental")
    tables$used_cdata <- load_data(input$exemplary_files, cdata(),input$control_name, "control")
    })
  # get the number of rows
  erow <- reactive({nrow(tables$used_edata)})
  crow <- reactive({nrow(tables$used_cdata)})
  # check if the files have different content
  observeEvent(c(tables$used_edata, tables$used_cdata), 
               {
                 validate(need(tables$used_edata, ''), need(tables$used_cdata, ''))
                 if(erow()==crow()) {if(all(tables$used_cdata==tables$used_edata)) {shinyalert("Warning","Uploaded files have the same content",
                                                                                     type="warning")}}
               })
  # display the tables and their lengths
  output$ccontents <- renderTable({tables$used_cdata}, align='c')
  output$econtents <- renderTable({tables$used_edata}, align='c')
  output$ncontrol <- renderText({crow()})
  output$nexp <- renderText({erow()})
  # calculate and show TES, plot
  output$plot <- renderPlot({
    validate(need(tables$used_edata, "Specify the correct experimental treatment."), need(tables$used_cdata, "Specify the correct control treatment."))
    withBusyIndicatorServer("generate_plot",
    {v$res_TES <- calculate_TES(v$method, tables$used_cdata, tables$used_edata)
    if (v$res_TES[["TES"]][["TES"]] >0){
      v$caption <- paste("RMST increase:", v$res_TES[["TES"]][["TES"]]*4.952, "month(s)", sep=" ")
      v$gen <- grid.arrange(v$res_TES[["Plot1"]] + plot_theme, 
                            v$res_TES[["Plot2"]] + plot_theme+ labs(caption=v$caption) +
                              theme(plot.caption=element_text(size=18, hjust=0, margin=margin(15,15,0,0))), 
                            nrow=2)
      v$to_save <- grid.arrange(v$res_TES[["Plot1"]], 
                                v$res_TES[["Plot2"]]+ labs(caption=v$caption) +
                                  theme(plot.caption=element_text(size=18, hjust=0, margin=margin(15,15,0,0))), 
                                nrow=2)
    }else{
      v$gen <- grid.arrange(v$res_TES[["Plot1"]] + plot_theme, 
                            v$res_TES[["Plot2"]] + plot_theme, 
                            nrow=2)
      v$to_save <- grid.arrange(v$res_TES[["Plot1"]], 
                                v$res_TES[["Plot2"]], 
                                nrow=2)
    }
    v$gen})
    }, height=565, width=550, bg="transparent", execOnResize = TRUE)
  # prepare plot for download
  output$downloadData1 <- downloadHandler(
    filename = function() {
      paste("TES_plot_", input$control_name, "_", input$exp_name, ".pdf", sep="")
    },
    content = function(file) {
      ggsave(v$to_save, filename = file)
    }
    )
  output$downloadData2 <- downloadHandler(
    filename = function() {
      paste("TES_plot_", input$control_name, "_", input$exp_name, ".tiff", sep="")
    },
    content = function(file) {
      ggsave(v$to_save, filename = file)
    }
  )
  # show the download button
  observeEvent(v$res_TES, {
    if (is.null(tables$used_edata) || is.null(tables$used_cdata)){
      shinyjs::hide("downloadData1")
      shinyjs::hide("downloadData2")
    }else{
      shinyjs::show("downloadData1")
      shinyjs::show("downloadData2")
    }
  })
}
