################################################################################
#### Level 1 Functions
################################################################################
#' Function to download CHIRPS data
#'
#' Function to download CHIRPS raster data
#' @export
#' @param tres numeric. Temporal resolution. \code{"daily"} or \code{"monthly"}
#' @param sres numeric. Spatial resolution. \code{0.05} or \code{0.25}. Note
#' that monthly data is only available at a resolution of 0.05 degrees.
#' @param dates date. Date(s) for which you want to download CHIRPS data
#' @param dsn path. Directory to which you want to store the downloaded data
#' @param overwrite logical. In case the file already exists, should it be
#' overwritten?
#' @return \code{RasterStack}
#' @examples
#' \dontrun{
#' # Load raster package
#' library(raster)
#'
#' # Download data
#' files <- getCHIRPS(
#'     tres       = "daily"
#'   , sres       = 0.25
#'   , dates      = as.Date("2016-12-31")
#'   , dsn        = tempdir()
#'   , overwrite  = T
#' )
#'
#' # Load the files as a rasterstack
#' rain <- stack(files)
#'
#' # Reclassify values (get rid of -9999)
#' rain <- reclassify(rain, c(-Inf, 0, NA))
#'
#' # Visualize
#' plot(rain)
#'}
getCHIRPS <- function(
    tres      = "monthly"
  , sres      = 0.05
  , dates     = NULL
  , dsn       = getwd()
  , overwrite = FALSE
  ){

  if (sres == 0.25 & tres == "monthly"){
    warning("Monthly data is only available at a resolution of 0.05 degrees...\n
    downloading at 0.05 degrees resolution.")
  }

  # Coerce date
  dates <- as.Date(dates)

  # Prepare filenames
  filenames <- .filename(dates = dates, tres = tres, sres = sres)

  # Get all urls (keep only uniques)
  url <- .urlprep(dates = dates, tres = tres, sres = sres, filenames = filenames)

  # Define the destination
  destfile <- paste0(dsn, "/", filenames)

  # Define the unzipped filename
  destfile_unzip <- gsub(pattern = ".gz", "", destfile)

  # Prepare an empty vector
  exists <- rep(FALSE, length(url))

  # Download files
  for (i in 1:length(url)){

    # Check if the file already exists as tif
    if (file.exists(destfile_unzip[i]) & overwrite == FALSE){

      # If it exists, we tell the user...
      print(paste0("File already exists"))
      exists[i] <- TRUE

      # ... and we skip an iteration
      next
    } else {

      # Otherwise we download the file
      download.file(url[i], destfile = destfile[i], quiet = TRUE)
    }
  }

  # For those files that are zipped we need to unzip them
  index <- grep(".gz", destfile)
  index <- index[index %in% which(!exists)]
  if (length(index) > 0){
    for (i in 1:length(index)){
      R.utils::gunzip(destfile[index[i]]
        , overwrite = overwrite
        , destname = destfile_unzip[i]
      )}
  }

  # Return the file paths
  return(destfile_unzip)
}

################################################################################
#### Level 2 Functions
################################################################################
# Function to determine filename of the desired raster
.filename <- function(dates, tres, sres){

  # Determine filenames for daily images
  if (tres == "daily"){
    filename <- paste0("chirps-v2.0.", format(dates, "%Y.%m.%d"), ".tif")

    # Daily images before a certain date are zipped. The date depends on sres
    if (sres == 0.05){
      index <- which(dates <= as.Date("2020-06-30"))
    } else {
      index <- which(dates <= as.Date("2017-06-30"))
    }

    # Adjust the url
    filename[index] <- paste0(filename[index], ".gz")

  # Determine filenames for monthly images
  } else {
    filename <- paste0("chirps-v2.0.", format(dates, "%Y.%m"), ".tif.gz")
  }

  # Keep only unique filenames
  filename <- unique(filename)

  # Return the filename
  return(filename)

}

# Function to prepare URL pointing at desired raster
.urlprep <- function(dates, tres, sres, filenames){

  # Define the fixed part of the url
  fixed <- "https://data.chc.ucsb.edu/products/CHIRPS-2.0/"

  # Define the variable part, depending on daily or monthly data
  if (tres == "daily"){

    # For daily images
    variable <- paste0("global_daily/tifs/p"
      , substr(sres, start = 3, stop = 4)
      , "/"
      , lubridate::year(dates)
      , "/"
      , filenames
    )
    url <- paste0(fixed, "/", variable)
    return(url)

  } else {

    # For monthly images
    variable <- paste0("global_monthly/tifs/", filenames)
    url <- paste0(fixed, "/", variable)
    return(url)

  }
}
