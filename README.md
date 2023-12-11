
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rainmapr <img src="man/figures/rainmapr.png" align="right" width="150" height="150"/>

`rainmapr` is an R-package that allows you to download CHIRPS data in
raster format. At the moment, data can only be downloaded globally. Data
is available at 0.25 and 0.05 degrees resolution and either as daily or
monthly averaged product.

## Installation

You can install the development version of rainmapr from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("DavidDHofmann/rainmapr")
```

## Example

Here is a little example how you can download data

``` r
# Load required packages
library(terra)
library(rainmapr)

# Download chirps data
chirps_files <- getCHIRPS(
    tres      = "monthly"
  , sres      = 0.05
  , dates     = c("2020-06-01", "2020-12-01")
  , dsn       = tempdir()
  , overwrite = T
)

# Load data into the r session
r <- rast(chirps_files)

# Reclassify values for easier plotting
r <- classify(r, rcl = cbind(-Inf, 0, NA))

# Visualize
plot(r, nr = 2)
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />
