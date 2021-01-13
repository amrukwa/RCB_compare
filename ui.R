source("helpers.R")

ui <- fluidPage(
                tags$head(tags$style(css)),
                theme = shinytheme("slate"),
                shinyjs::useShinyjs(),
                useShinyalert(),
                br(),
                sidebarLayout(sidebarPanel2(selectInput("method", 
                                         label = "Select TES calculation method",
                                         choices = list(
                                                        "Density ratio of RCB scores from two treatments"="DensRatio",
                                                        "eCDF difference of RCB scores from two treatments"="wKS",
                                                        "Density difference of RCB scores from two treatments"= "DensDiff"),
                                         selected = "wKS"),
                             tags$div(title=inf_name, textInput("control_name", 
                                                                "Name of the control treatment", "Control")),
                             tags$div(title=inf_file, fileInput(inputId = "control_file",
                                                                label = "Upload the RCB scores from control treatment",
                                                                accept = ".txt")),
                             tags$div(title=inf_name, textInput("exp_name", 
                                                                "Name of the experimental treatment", "Experimental")),
                             tags$div(title=inf_file, fileInput(inputId = "exp_file",
                                                                label = "Upload the RCB scores from experimental treatment",
                                                                accept = ".txt")),
                             fluidRow(column(3, tags$div(title=exemp, prettySwitch(inputId = "exemplary_files",
                                                                 label = "Use exemplary data instead", fill=TRUE)))),
                             fluidRow(column(3, withBusyIndicatorUI(actionButton(inputId = "generate_plot",
                                                              label = "Calculate", class = "btn-primary"))),
                             column(3, div(img(src='polsl.png', align = "top", width="200%")), offset=3)),
                             br(),
                             fluidRow(column(1, HTML(paste0("N",tags$sub("control"), ": "))),  
                             column(2, textOutput("ncontrol"), offset=1),
                             column(3, div(img(src='yale.png', align = "top", width="230%")), offset=2)), 
                             fluidRow(column(1, HTML(paste0("N",tags$sub("experimental"), ": "))), 
                             column(2, textOutput("nexp"), offset=1)
                             ),
                             br(),
                             width = 4
                ),
                mainPanel(tabsetPanel(
                  tabPanel("Data", br(), h4("Patient level RCB score"), 
                           div(style = "width:auto;height:840px;overflow-y:scroll;",
                           column(1, shinycssloaders::withSpinner(tableOutput("ccontents"), color = "#708090")), 
                           column(1, shinycssloaders::withSpinner(tableOutput("econtents"), color = "#708090")),
                           tags$head(tags$style("#ccontents table {background-color: white; color: black; }", media="screen", type="text/css")),
                           tags$head(tags$style("#econtents table {background-color: white; color: black; }", media="screen", type="text/css")),
                           column(8, ""))
                  ),
                  tabPanel("TES Plots", shinycssloaders::withSpinner(plotOutput("plot", width = "100%", height = "100%"), color = "#708090"), 
                          br(), 
                          fluidRow(column(10, div(shinyjs::hidden(downloadButton("downloadData1", "Download plots as pdf")), style = "float: left"),
                                          div(shinyjs::hidden(downloadButton("downloadData2", "Download plots as tiff")), style = "float: center"), 
                                          offset=1)
                                   )
                          ), type='pills'
                )))
)
