library(shiny)
library(dplyr)
library(ggplot2)
library(lme4)
library(rlang)
library(baplot)



#-------------------------------------------------------#
#   0- GENERATE EXAMPLE DATA                            #
#-------------------------------------------------------#
trial_props <- c(1, 2, 1, 3, 1)
trial_counts <- round(trial_props / sum(trial_props) * 500)
trial_counts[5] <- 500 - sum(trial_counts[1:4]) # Ensure total is 500

set.seed(12345)
example <- data.frame(
    Trial = rep(1:5, times = trial_counts),
    Participant_id = 1:500,
    Scale1 = rnorm(500, mean = 1.27, sd = 1.28),
    Scale2 = rnorm(500, mean = 2.08, sd = 1.91)
)

rm(trial_props, trial_counts)



#-------------------------------------------------------#
#   1- UI                                               #
#-------------------------------------------------------#

ui <- fluidPage(
    titlePanel("Bland\u2013Altman Plot"),

    sidebarLayout(
        sidebarPanel(

            # --- Data source ------------------------------------------------------
            radioButtons("data_source", "Data Source",
                         choices  = c("Use example data" = "example",
                                      "Upload my data"   = "upload"),
                         selected = "example"), # example by default

            conditionalPanel(
                condition = "input.data_source == 'upload'",
                fileInput("user_file", "Upload CSV. Please include columns for trial,
                          participant ID, score from rater 1, and score for rater 2.",

                          accept = c("text/csv", ".csv"))
            ),

            hr(),


            # --- Column mapping ---------------------------------------------------
            selectInput("trial", "Trial", choices = NULL),
            selectInput("id", "Participant ID", choices = NULL),
            selectInput("rater1", "Rater 1", choices = NULL),
            selectInput("rater2", "Rater 2", choices = NULL),

            hr(),


            # --- Options ----------------------------------------------------------
            checkboxInput("use_colour",      "Colour by trial",        value = TRUE),
            checkboxInput("show_unadjusted", "Show unadjusted lines",  value = FALSE),


            textInput("scale1_name", "Rater 1 label", value = "Rater 1"),
            textInput("scale2_name", "Rater 2 label", value = "Rater 2"),

            actionButton("plot_btn", "Generate Plot", class = "btn-primary")
        ),

        mainPanel(
            plotOutput("ba_plot", height = "550px")
        )
    )
)



#-------------------------------------------------------#
#   2- SERVER                                           #
#-------------------------------------------------------#

server <- function(input, output, session) {

    # 1. Reactive data: example vs uploaded -----------------------------
    data_reactive <- reactive({
        if (input$data_source == "example") {
            # example is the data.frame you created:
            # Trial, Participant_id, Scale1, Scale2
            example
        } else {
            req(input$user_file)  # wait until file is uploaded
            read.csv(input$user_file$datapath)
        }
    })

    # 2. Update column choices and defaults once data is available ------
    observe({
        df   <- data_reactive()
        cols <- names(df)

        if (input$data_source == "example") {
            # set sensible defaults for example data
            updateSelectInput(
                session, "trial",
                choices  = cols,
                selected = "Trial"
            )
            updateSelectInput(
                session, "id",
                choices  = cols,
                selected = "Participant_id"
            )
            updateSelectInput(
                session, "rater1",
                choices  = cols,
                selected = "Scale1"
            )
            updateSelectInput(
                session, "rater2",
                choices  = cols,
                selected = "Scale2"
            )
        } else {
            # uploaded data: just offer choices, let user decide
            updateSelectInput(session, "trial",  choices = cols)
            updateSelectInput(session, "id",     choices = cols)
            updateSelectInput(session, "rater1", choices = cols)
            updateSelectInput(session, "rater2", choices = cols)
        }
    })

    # 3. React to "Generate Plot" button --------------------------------
    bland_altman_plot <- eventReactive(input$plot_btn, {
        df <- data_reactive()

        # turn selected column names (characters) into symbols for {{ }}
        r1  <- rlang::sym(input$rater1)
        r2  <- rlang::sym(input$rater2)
        tr  <- rlang::sym(input$trial)
        idv <- rlang::sym(input$id)

        plot_bland_altman(
            data            = df,
            rater1          = !!r1,
            rater2          = !!r2,
            trial_var       = !!tr,
            id_var          = !!idv,
            use_colour      = input$use_colour,
            show_unadjusted = input$show_unadjusted,
            scale1_name     = input$scale1_name,
            scale2_name     = input$scale2_name,
            plot_title      = "Bland–Altman Plot"
        )
    })

    # 4. Send plot to UI -------------------------------------------------
    output$ba_plot <- renderPlot({
        bland_altman_plot()
    })
}




#-------------------------------------------------------#
#   3- RUN APP                                          #
#-------------------------------------------------------#

shinyApp(ui = ui, server = server)
