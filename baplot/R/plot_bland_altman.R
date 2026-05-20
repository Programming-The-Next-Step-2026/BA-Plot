# Function that find and launch the shiny app

#' Plot the Bland-Altman plot
#' @details Plot the Bland-Altman plot
#' @importFrom dplyr mutate
#' @importFrom lme4 lmer fixef
#' @importFrom ggplot2 ggplot aes geom_point geom_hline annotate scale_x_continuous labs theme_classic ylim scale_colour_brewer expansion
#' @importFrom stats quantile sd
#' @param data Dataset
#' @param rater1 Scores from the first rater
#' @param rater2 Scores from the first rater
#' @param trial_var Column indiciating the trial each participant is from
#' @param id_var Participant ID
#'
#' @examples
#' # basic Bland–Altman plot using the included example data
#' plot_bland_altman(
#'   data      = example,
#'   rater1    = Scale1,
#'   rater2    = Scale2,
#'   trial_var = Trial,
#'   id_var    = Participant_id
#' )
#'
#' @export

plot_bland_altman <- function(data,
                              rater1,
                              rater2,
                              trial_var,
                              id_var,
                              use_colour      = TRUE,
                              show_unadjusted = FALSE,
                              scale1_name     = "Scale 1",
                              scale2_name     = "Scale 2",
                              plot_title      = "Bland\u2013Altman Plot") {

  # 1. Create Bland-Altman variables ----------------------------------------
  df_ba <- data |>
    mutate(
      participant_id = {{ id_var }},
      trial          = {{ trial_var }},
      score1         = {{ rater1 }},
      score2         = {{ rater2 }},
      mean_score     = (score1 + score2) / 2,
      diff_score     = score1 - score2
    )

  # 2. Unadjusted stats (always computed, plotted only if show_unadjusted = TRUE)
  unadj_mean <- mean(df_ba$diff_score, na.rm = TRUE)
  unadj_sd   <- sd(df_ba$diff_score,   na.rm = TRUE)
  unadj_upper <- unadj_mean + 1.96 * unadj_sd
  unadj_lower <- unadj_mean - 1.96 * unadj_sd

  # 3. Adjusted mean and LoA (default, always plotted) ----------------------
  model_bias  <- lmer(diff_score ~ 1 + (1 | trial), data = df_ba)
  adj_mean    <- fixef(model_bias)[["(Intercept)"]]
  adj_resid   <- residuals(model_bias)
  adj_sd      <- sd(adj_resid)
  adj_upper   <- adj_mean + 1.96 * adj_sd
  adj_lower   <- adj_mean - 1.96 * adj_sd

  # 4. Horizontal segment x-range -------------------------------------------
  x_limits <- quantile(df_ba$mean_score, probs = c(0.01, 0.99), na.rm = TRUE)

  # 5. Symmetric y-limits ---------------------------------------------------
  all_lines <- c(adj_upper, adj_lower, adj_mean)
  if (show_unadjusted) all_lines <- c(all_lines, unadj_upper, unadj_lower, unadj_mean)
  max_abs <- max(abs(df_ba$diff_score), abs(all_lines), na.rm = TRUE)
  y_lim   <- max_abs + 0.5

  # 6. X-axis limits and breaks ---------------------------------------------
  x_min    <- min(df_ba$mean_score, na.rm = TRUE) - 0.5
  x_max    <- max(df_ba$mean_score, na.rm = TRUE) + 0.5
  x_breaks <- seq(ceiling(x_min), floor(x_max), by = 1)

  # 7. Base plot ------------------------------------------------------------
  p <- ggplot(df_ba, aes(x = mean_score, y = diff_score)) +

    geom_hline(yintercept = 0, linetype = "dashed") +

    # --- Adjusted lines (black, solid — default) --------------------------
  annotate("segment",
           x = x_limits[1], xend = x_limits[2],
           y = adj_mean,     yend = adj_mean,
           linewidth = 0.6, colour = "black") +
    annotate("segment",
             x = x_limits[1], xend = x_limits[2],
             y = adj_upper,   yend = adj_upper,
             linewidth = 0.6, colour = "black") +
    annotate("segment",
             x = x_limits[1], xend = x_limits[2],
             y = adj_lower,   yend = adj_lower,
             linewidth = 0.6, colour = "black") +

    # Adjusted labels
    annotate("text",
             x = x_limits[2], y = adj_mean,
             label = paste0("Adj. Mean (", round(adj_mean, 2), ")"),
             hjust = -0.05, vjust = 0.5, size = 4.5, colour = "black") +
    annotate("text",
             x = x_limits[2], y = adj_upper,
             label = paste0("Adj. Mean + 1.96SD (", round(adj_upper, 2), ")"),
             hjust = 0.1, vjust = -1, size = 4.5, colour = "black") +
    annotate("text",
             x = x_limits[2], y = adj_lower,
             label = paste0("Adj. Mean \u2212 1.96SD (", round(adj_lower, 2), ")"),
             hjust = 0.1, vjust = 2, size = 4.5, colour = "black") +

    ylim(-y_lim, y_lim) +
    scale_x_continuous(
      limits = c(x_min, x_max),
      breaks = x_breaks,
      expand = expansion(mult = c(0.05, 0.25))
    ) +
    labs(
      x     = paste0("Mean of ", scale1_name, " and ", scale2_name),
      y     = paste0(scale1_name, " \u2212 ", scale2_name),
      title = plot_title
    ) +
    theme_classic(base_size = 14)

  # 8. Optionally add unadjusted lines (gray, dashed) -----------------------
  if (show_unadjusted) {
    p <- p +
      annotate("segment",
               x = x_limits[1], xend = x_limits[2],
               y = unadj_mean,   yend = unadj_mean,
               linewidth = 0.6, linetype = "dashed", colour = "gray50") +
      annotate("segment",
               x = x_limits[1], xend = x_limits[2],
               y = unadj_upper,  yend = unadj_upper,
               linewidth = 0.6, linetype = "dashed", colour = "gray50") +
      annotate("segment",
               x = x_limits[1], xend = x_limits[2],
               y = unadj_lower,  yend = unadj_lower,
               linewidth = 0.6, linetype = "dashed", colour = "gray50") +
      annotate("text",
               x = x_limits[2], y = unadj_mean,
               label = paste0("Mean (", round(unadj_mean, 2), ")"),
               hjust = -0.05, vjust = 0.5, size = 4, colour = "gray50") +
      annotate("text",
               x = x_limits[2], y = unadj_upper,
               label = paste0("Mean + 1.96SD (", round(unadj_upper, 2), ")"),
               hjust = 0.1, vjust = -1, size = 4, colour = "gray50") +
      annotate("text",
               x = x_limits[2], y = unadj_lower,
               label = paste0("Mean \u2212 1.96SD (", round(unadj_lower, 2), ")"),
               hjust = 0.1, vjust = 2, size = 4, colour = "gray50")
  }

  # 9. Add points, optionally coloured by trial -----------------------------
  if (use_colour) {
    p <- p +
      geom_point(aes(colour = factor(trial)), size = 2, alpha = 0.8) +
      scale_colour_brewer(palette = "Paired", name = "Trial")
  } else {
    p <- p +
      geom_point(colour = "black", size = 2, alpha = 0.8, shape = 1, stroke = 1)
  }

  p
}
