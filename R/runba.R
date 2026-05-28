# Function that find and launch the shiny app

#' Launch the Shiny application
#' @details Launch the app
#' @examples
#' runBA()
#'
#' @export
runBA <- function() {
  appDir <- system.file("shiny", "baplot", package = "baplot")
  if (appDir == "") {
    stop("Could not find file directory. Try re-installing `baplot`.", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal")
}
