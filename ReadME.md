
## What is Hedges g?

A central component of Evidence Synthesis is the effect size. An effect size is, quite simply, the size of the effect. It is a way to quantify the difference between two groups. The effect size is a standardised measurement of the difference between two groups (e.g. the treatment group and the control group). A simple measure of effect is the standardised mean difference (often expressed as Cohen’s d or the small-sample bias corrected version Hedges’ g). Standardised mean difference simply quantifies how much of a difference there is between the control and treatment group.

## Why do we need this App?

Standardised mean difference require the standard deviations of the two groups (control and treatment) to estimate the effect size's precision (the uncertainty) which gives us the 95% confidence limits. In many published studies the standard deviation is not reported making it difficult to calculate an effect size without making some big assumptions about the underlying data.

Often the standard error is mistakenly reported as the standard deviation, this has a big effect on the calculation of the standardised mean difference. If you calculate a very large (greater than 5) Hedges' g estimate you might want to check the calculation and the original paper to make sure that the data has been extracted correctly. 

### The underlying data

The data used are ecological. Different subject areas will have different typical effect sizes. 

Currently the underlying distribution comes from [Fox 2022](https://doi.org/10.1002/ece3.9521). These are 7436 Hedges g effect sizes. The original data had 8396 studies but several had clear errors (Effect sizes over 100 for example!), so I used the first and third quartiles to identify and remove any outliers.

## How to run the App?

You can launch the App [here](https://drmatt.shinyapps.io/Hedges_g_checker/)

Upload your data with Hedges g in it. Navigate to the correct column and then press "Go". After a few minutes you will see a plot of the distribution of typical effect sizes (blue distribution; from the Fox 2022 dataset) along with red lines that indicate your Hedges g values. If your values fall outside the typical effect sizes you may wish to check the calculation and data extraction. 

## Bugs and improvements

Please report bugs using the [issues in the repo](https://github.com/DrMattG/Hedges_g/issues)

If you want to suggest improvements to the code (there are many potential improvements!) please submit a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests)



