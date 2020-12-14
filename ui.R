source("helpers.R")

ui <- fluidPage(#tags$head(tags$style(css)),
                theme = shinytheme("slate"),
                shinyjs::useShinyjs(),
                useShinyalert(),
                br(),
                sidebarPanel2(selectInput("method", 
                                         label = "Select TES calculation method",
                                         choices = list("Weighted two-sample Kolmogorov-Smirnov test"="wKS", 
                                                        "Density ratio of RCB scores from two treatments"="DensRatio",
                                                        "Density difference of RCB scores from two treatments"= "DensDiff"),
                                         selected = "Weighted two-sample Kolmogorov-Smirnov test"),
                             tags$div(title=inf_name, textInput("control_name", 
                                                                "Name of the control treatment", "Control")),
                             tags$div(title=inf_file, fileInput(inputId = "control_file",
                                                                label = "Upload the RCB scores from control treatment",
                                                                accept = c(".txt"))),
                             tags$div(title=inf_name, textInput("exp_name", 
                                                                "Name of the experimental treatment", "Experimental")),
                             tags$div(title=inf_file, fileInput(inputId = "exp_file",
                                                                label = "Upload the RCB scores from experimental treatment",
                                                                accept = c(".txt"))),
                             tags$div(title=exemp, checkboxInput(inputId = "exemplary_files",
                                                                 label = "Use exemplary data instead")),
                             column(3, withBusyIndicatorUI(actionButton(inputId = "generate_plot",
                                                              label = "Calculate", class = "btn-primary"))),
                             column(3, div(img(src='polsl.png', align = "top", width="200%")), offset=3),
                             
                             br(), br(), br(),
                             column(1, HTML(paste0("N",tags$sub("control"), ": "))),  
                             column(2, textOutput("ncontrol"), offset=1), br(),
                             column(1, HTML(paste0("N",tags$sub("experimental"), ": "))), 
                             column(2, textOutput("nexp"), offset=1),
                             column(3, div(img(src='yale.png', align = "top", width="250%")), offset=2),
                             br(), br(), br(),
                             out = includeHTML("www/include.html")
                ),
                mainPanel(tabsetPanel(
                  tabPanel("Data", br(), h4("Patient level RCB score"),
                           column(1, shinycssloaders::withSpinner(tableOutput("ccontents"))), 
                           column(1, shinycssloaders::withSpinner(tableOutput("econtents")))
                  ),
                  tabPanel("TES Plots", shinycssloaders::withSpinner(plotOutput("plot", width = "100%", height = "100%")), 
                          br(), 
                          fluidRow(column(10, div(shinyjs::hidden(downloadButton("downloadData1", "Download plots as pdf")), style = "float: left"),
                                          div(shinyjs::hidden(downloadButton("downloadData2", "Download plots as tiff")), style = "float: center"), 
                                          offset=1)
                                   )
                          )
                ))
)
