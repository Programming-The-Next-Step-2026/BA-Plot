# baplot

This Shiny app will allow the user to create a Bland-Altman plot (BA plot; Bland & Altman, 1999) using the example data or a csv file of their data. In comparison to existing BA plot Shiny apps, the current app will allow the user to colour data points from different trials.

The primary plot will be the basic Bland-Altman plot (Bland & Altman, 1999; Figure 3). It will feature the difference of two raters plotted against the average of the two raters. The user can choose to display the mean and limit of agreement. The user can further choose to display the trial adjusted mean bias and the mean per trial. 

In addition to the primary Bland-Altman plot, users will have the option to create a regression plot (to inspect systematic bias) and a ratio Bland-Altman plot (to correct for associations between the difference and the mean). 

I aim to make the plots interactive, such that if you hover over a point, it will display which trial the data point is from. Similarly, if you hover over a line representing the mean, it will tell you the value of the mean. Further features may be added if time permit. 





Citations:
Bland, J. M., & Altman, D. G. (1999). Measuring agreement in method comparison studies. Statistical Methods in Medical Research, 8(2), 135–160. https://doi.org/10.1177/096228029900800204


<!-- badges: start -->
[![R-CMD-check](https://github.com/Programming-The-Next-Step-2026/baplot/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Programming-The-Next-Step-2026/baplot/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->