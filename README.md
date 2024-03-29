
# rainmapr <img src="man/figures/rainmapr.png" align="right" width="150" height="150"/>

`rainmapr` is an R-package that allows you to download CHIRPS data in
raster format. At the moment, data can only be downloaded globally. Data
is available at 0.25 and 0.05 degrees resolution and either as daily or
monthly averaged product.

## Installation

To install `rainmapr` you need to have the package `devtools` installed.
You can then install `rainmapr` using:

``` r
library(devtools)
install_github("DavidDHofmann/rainmapr")
```

## Example

Here is a little example how you can download data

``` r
# Load required packages
library(raster)
library(rainmapr)

# Download chirps data
chirps_files <- getCHIRPS(
    tres      = "monthly"
  , sres      = 0.05
  , dates     = c("2020-06-01", "2020-12-01")
  , overwrite = T
)

# Load data into the r session
r <- stack(chirps_files)

# Reclassify
r <- reclassify(r, c(-Inf, 0, NA))

# Visualize
plot(r)
```
