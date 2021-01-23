
<!-- README.md is generated from README.Rmd. Please edit that file -->

# breakerofchains

<!-- badges: start -->

<!-- badges: end -->

Snap your chain at the cursor line. Run the first bit. See the output.
Be free.

## Installation

``` r
# install.packages("remotes")
remotes::install_github("MilesMcBain/breakerofchains")
```

## Usage

Say you had:

``` r
library(tidyverse)

starwars %>%
group_by(species, sex) %>%
select(height, mass) %>%
summarise(
height = mean(height, na.rm = TRUE),
mass = mean(mass, na.rm = TRUE)
) %>%
ggplot(aes(x = height, y = mass)) +
geom_point()
```

1.  Pop your cursor on line you want to run up to. e.g. `select(height,
    mass)`.

2.  Invoke the RStudio Addin `Break chain and run to cursor`

3.  Code is run in console from start of chain up to your cursor.
