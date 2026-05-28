test_that("plot_bland_altman creates a ggplot object", {
  skip_on_cran()  # plotting tests can be slow / fragile on CRAN

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

  p <- plot_bland_altman(
    data      = example,
    rater1    = Scale1,
    rater2    = Scale2,
    trial_var = Trial,
    id_var    = Participant_id
  )

  # should return a ggplot object
  expect_s3_class(p, "ggplot")
})
