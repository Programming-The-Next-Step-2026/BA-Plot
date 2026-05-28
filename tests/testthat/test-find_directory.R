test_that("runBA finds the app directory, should not be empty if runBA found the directory", {
  appDir <- system.file("shiny", "baplot", package = "baplot")
  expect_true(nzchar(appDir))
})



test_that("runBA returns the error message if found directory is empty", {
  fake_system_file <- function(...) ""   # returns ""
  with_mocked_bindings({expect_error(runBA(),
                                     "Could not find file directory. Try re-installing `baplot`.",
                                     fixed = TRUE)},

                       system.file = fake_system_file)
})
