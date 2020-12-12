source("helpers.R")

ui <- fluidPage(theme = shinytheme("slate"),
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
                                                                "Name of the control treatment", "control")),
                             tags$div(title=inf_file, fileInput(inputId = "control_file",
                                                                label = "Upload the RCB scores from control treatment",
                                                                accept = c(".txt"))),
                             tags$div(title=inf_name, textInput("exp_name", 
                                                                "Name of the experimental treatment", "experimental")),
                             tags$div(title=inf_file, fileInput(inputId = "exp_file",
                                                                label = "Upload the RCB scores from experimental treatment",
                                                                accept = c(".txt"))),
                             tags$div(title=exemp, checkboxInput(inputId = "exemplary_files",
                                                                 label = "Use exemplary data instead")),
                             column(1, withBusyIndicatorUI(actionButton(inputId = "generate_plot",
                                                              label = "Calculate", class = "btn-primary"))),
                             column(2),
                             column(3, img(src='polsl.png', align = "center", width="200%"), offset=1),
                             br(), br(), br(), br(),
                             column(1, HTML(paste0("N",tags$sub("control"), ": "))),  
                             column(2, textOutput("ncontrol"), offset=1), br(),
                             column(1, HTML(paste0("N",tags$sub("experimental"), ": "))), 
                             column(2, textOutput("nexp"), offset=1),
                             column(3, div(img(src='shield.jfif', align = "left", width="30%"),
                                           style="display: block; margin-left: 5px;"),
                             div(img(src='wordmark.jfif', width="350%"), 
                                 style="display: block; margin-left: 50px; margin-top: 10px; margin-right: auto;")),
                             br(), br(),
                             out = includeHTML("www/include.html")
                ),
                mainPanel(tabsetPanel(
                  tabPanel("Data", br(), h4("Patient level RCB score"),
                           column(1, shinycssloaders::withSpinner(tableOutput("ccontents"))), 
                           column(2, shinycssloaders::withSpinner(tableOutput("econtents")))
                  ),
                  tabPanel("TES Plots", shinycssloaders::withSpinner(plotOutput("plot", width = "100%", height = "100%")), 
                          br(), shinyjs::hidden(downloadButton("downloadData", "Download the plot")))
                ))
                
                
)
