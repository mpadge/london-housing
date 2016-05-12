Visualisation of London housing data using `osmplotr`
=====================================================

![](./figure/map.png)

1. Reading Data
---------------

Data on housing prices and transactions were taken from <http://data.london.gov.uk/dataset/average-house-prices-borough>, with spatial boundaries of the 'Lower Super Output Areas' (LSOA; the finest spatial scale) from <http://data.london.gov.uk/dataset/statistical-gis-boundary-files-london>

Because the links to these data files are likely to change, the script requires data to be downloaded first. Start by reading the housing price data (the 'DEFINEDNAME' stuff is just junk dumped from `read_excel`)

``` r
lf <- list.files ("./dat")
fi <- grep ("house-prices", lf)
fname <- paste0 ("./dat/", lf [fi])
housing <- readxl::read_excel (fname, sheet="LSOA11")
```

    ## DEFINEDNAME: 21 00 00 01 0b 00 00 00 02 00 00 00 00 00 00 0d 3b 00 00 00 00 00 00 3f 00 40 00 
    ## DEFINEDNAME: 21 00 00 01 0b 00 00 00 05 00 00 00 00 00 00 0d 3b 01 00 00 00 00 00 29 00 2a 00 
    ## DEFINEDNAME: 21 00 00 01 0b 00 00 00 02 00 00 00 00 00 00 0d 3b 00 00 00 00 00 00 3f 00 40 00 
    ## DEFINEDNAME: 21 00 00 01 0b 00 00 00 05 00 00 00 00 00 00 0d 3b 01 00 00 00 00 00 29 00 2a 00 
    ## DEFINEDNAME: 21 00 00 01 0b 00 00 00 02 00 00 00 00 00 00 0d 3b 00 00 00 00 00 00 3f 00 40 00 
    ## DEFINEDNAME: 21 00 00 01 0b 00 00 00 05 00 00 00 00 00 00 0d 3b 01 00 00 00 00 00 29 00 2a 00 
    ## DEFINEDNAME: 21 00 00 01 0b 00 00 00 02 00 00 00 00 00 00 0d 3b 00 00 00 00 00 00 3f 00 40 00 
    ## DEFINEDNAME: 21 00 00 01 0b 00 00 00 05 00 00 00 00 00 00 0d 3b 01 00 00 00 00 00 29 00 2a 00 
    ## DEFINEDNAME: 21 00 00 01 0b 00 00 00 02 00 00 00 00 00 00 0d 3b 00 00 00 00 00 00 3f 00 40 00 
    ## DEFINEDNAME: 21 00 00 01 0b 00 00 00 05 00 00 00 00 00 00 0d 3b 01 00 00 00 00 00 29 00 2a 00

``` r
# Table has "." for missing values
housing [housing == "."] <- NA
names (housing)
```

    ##  [1] "Lower Super Output Area" "Names"                  
    ##  [3] "Census 2011 dwellings"   "Median(£)-1995"         
    ##  [5] "Median(£)-1996"          "Median(£)-1997"         
    ##  [7] "Median(£)-1998"          "Median(£)-1999"         
    ##  [9] "Median(£)-2000"          "Median(£)-2001"         
    ## [11] "Median(£)-2002"          "Median(£)-2003"         
    ## [13] "Median(£)-2004"          "Median(£)-2005"         
    ## [15] "Median(£)-2006"          "Median(£)-2007"         
    ## [17] "Median(£)-2008"          "Median(£)-2009"         
    ## [19] "Median(£)-2010"          "Median(£)-2011"         
    ## [21] "Median(£)-2012"          "Median(£)-2013"         
    ## [23] "Median(£)-2014"          "Sales-1995"             
    ## [25] "Sales-1996"              "Sales-1997"             
    ## [27] "Sales-1998"              "Sales-1999"             
    ## [29] "Sales-2000"              "Sales-2001"             
    ## [31] "Sales-2002"              "Sales-2003"             
    ## [33] "Sales-2004"              "Sales-2005"             
    ## [35] "Sales-2006"              "Sales-2007"             
    ## [37] "Sales-2008"              "Sales-2009"             
    ## [39] "Sales-2010"              "Sales-2011"             
    ## [41] "Sales-2012"              "Sales-2013"             
    ## [43] "Sales-2014"

Convert data columns to numeric:

``` r
for (i in 3:ncol (housing)) housing [,i] <- as.numeric (housing [,i])
```

Then the LSOA boundaries, in the file 'LSOA\_2011\_London\_gen\_MHW.shp' contained in the zip archive 'statistical-gis-boundaries-london.zip'. These data are in Ordnance Survey National Grid format which must be input in the `proj4string`.

``` r
fi <- grep ('LSOA\\w+.shp$', lf)
fname <- paste0 ('./dat/', lf [fi])
boundaries <- maptools::readShapePoly (fname, 
                                       proj4string=sp::CRS ('+init=epsg:27700'))
sp::bbox (boundaries)
```

    ##        min      max
    ## x 503574.2 561956.7
    ## y 155850.8 200933.6

Transform the CRS to WGS84:

``` r
boundaries <- sp::spTransform (boundaries, 
                               CRS=sp::CRS("+proj=longlat +datum=WGS84"))
bbox <- sp::bbox (boundaries)
bbox
```

    ##          min        max
    ## x -0.5102996  0.3339955
    ## y 51.2867601 51.6918728

``` r
head (slot (boundaries, "data"))
```

    ##    LSOA11CD                  LSOA11NM  MSOA11CD                 MSOA11NM
    ## 0 E01000001       City of London 001A E02000001       City of London 001
    ## 1 E01000002       City of London 001B E02000001       City of London 001
    ## 2 E01000003       City of London 001C E02000001       City of London 001
    ## 3 E01000005       City of London 001E E02000001       City of London 001
    ## 4 E01000006 Barking and Dagenham 016A E02000017 Barking and Dagenham 016
    ## 5 E01000007 Barking and Dagenham 015A E02000016 Barking and Dagenham 015
    ##     LAD11CD              LAD11NM   RGN11CD RGN11NM USUALRES HHOLDRES
    ## 0 E09000001       City of London E12000007  London     1465     1465
    ## 1 E09000001       City of London E12000007  London     1436     1436
    ## 2 E09000001       City of London E12000007  London     1346     1250
    ## 3 E09000001       City of London E12000007  London      985      985
    ## 4 E09000002 Barking and Dagenham E12000007  London     1703     1699
    ## 5 E09000002 Barking and Dagenham E12000007  London     1391     1391
    ##   COMESTRES POPDEN HHOLDS AVHHOLDSZ
    ## 0         0  112.9    876       1.7
    ## 1         0   62.9    830       1.7
    ## 2        96  227.7    817       1.5
    ## 3         0   52.0    467       2.1
    ## 4         4  116.2    543       3.1
    ## 5         0   69.6    612       2.3

### 1.1 Downloading OSM data

``` r
devtools::install_github ('mpadge/osmplotr')
```

Download an area of central London surrounding Hyde Park

``` r
bbox <- osmplotr::get_bbox (c (-0.2, 51.48, -0.1, 51.52))
dat_HP <- osmplotr::extract_osm_objects (key="highway", bbox=bbox, verbose=TRUE)
save (dat_H, file="./dat/dat_H.rda", compress="xz")
pt <- proc.time ()
dat_B <- osmplotr::extract_osm_objects (key="building", bbox=bbox,
                                        verbose=TRUE)
dt <- proc.time () - pt
save (dat_B, file="./dat/dat_B.rda", compress="xz")
```

``` r
load ("./dat/dat_H.rda")
load ("./dat/dat_B.rda")
```

``` r
length (dat_H)
```

    ## [1] 12538

``` r
length (dat_B)
```

    ## [1] 19548

------------------------------------------------------------------------

2. Mapping data with `osmplotr`
-------------------------------

### 2.1 2015 House Prices

Map the 2014 house prices

``` r
prices <- housing [, grep ("^Median.+2014$", names (housing))]
```

Then get the corresponding LSOA codes for each point

``` r
snames <- as.character (housing [,grep("Lower.Super", names(housing))])
indx <- order (snames)
prices <- prices [indx]
snames <- snames [indx]
```

The `add_osm_surface` function from `osmplotr` interpolates a continuous surface between a set of discrete values. The values for each LSOA can be attributed to its central point, so first extract those:

``` r
bpts <- t (sapply (slot (boundaries, "polygons"), function (x) slot (x, "labpt")))
bnames <- as.character (slot (boundaries, "data")$LSOA11CD)
indx <- order (bnames)
bpts <- bpts [indx,]
bnames <- bnames [indx]
```

Then check that the LSOA code names in housing match those of the boundary polygons

``` r
all (bnames == snames)
```

    ## [1] TRUE

Then join data together

``` r
dat <- data.frame (cbind (bpts, prices))
names (dat) <- c ("x", "y", "z")
dat <- dat [!is.na (dat$z),]
head (dat)
```

    ##             x        y      z
    ## 1 -0.09677757 51.51801 720000
    ## 2 -0.09255320 51.51821 836500
    ## 3 -0.09581278 51.52172 487500
    ## 4 -0.07581061 51.51355 414500
    ## 5  0.08844056 51.53898 267500
    ## 6  0.07704955 51.54043 154500

There are a small number of extremely expensive properties, so all values greater than £1,000,000 points are set to that value

``` r
zlim <- 1000000
dat$z [dat$z > zlim] <- zlim
```

Cut the price data down to values within the bbox only

``` r
bbox <- slot (dat_B, "bbox")
indx <- which (dat$x > bbox [1,1] & dat$x < bbox [1,2] &
               dat$y > bbox [2,1] & dat$y < bbox [2,2])
dat <- dat [indx,]
```

Then simply plot the surface with a scale bar in hundreds of thousands of pounds

``` r
map <- plot_osm_basemap (bbox=bbox, bg="gray20")
cols <- rev (heat.colors (50))
map <- add_osm_surface (map, dat_B, dat=dat, col=cols)
map <- add_osm_surface (map, dat_H, dat=dat, col=adjust_colours (cols, -0.2))
map <- add_colourbar (map, cols=cols, zlims=range (dat$z) / 1e5)
```

Finally, add a text label to the map and print it

``` r
ypos <- bbox [2,1] + 0.92 * diff (bbox [2,])
dat <- data.frame (x=mean (bbox[1,]), y=ypos,
                   lab="London house prices")
aes <- ggplot2::aes (x, y, label=lab)
map <- map + ggplot2::geom_text (dat=dat, mapping=aes, size=10, colour="black",
                                 family="Lato Light", fontface=2,
                                 nudge_y=0.0005, nudge_x=0.0005)
map <- map + ggplot2::geom_text (dat=dat, mapping=aes, size=10, colour="white",
                                 family="Lato Light", nudge_y=0.001, fontface=2)
print (map)
```

![](./figure/map.png)
