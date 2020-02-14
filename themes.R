# experimental levels
charlevels <- c("control", "bldg", 
                "lay", "inc.d3", "inc.d9", "inc.d17", 
                "hatch", "n5", "n9")
sexlevels <- c("female", "male")
tissuelevels <- c("hypothalamus", "pituitary", "gonad")

# experimental colors
colorschar <-  c("control" = "#cc4c02", 
                 "bldg"= "#fe9929", 
                 "lay"= "#fed98e", 
                 "inc.d3"= "#78c679", 
                 "inc.d9"= "#31a354", 
                 "inc.d17"= "#006837", 
                 "hatch"= "#08519c",
                 "n5"= "#3182bd", 
                 "n9"= "#6baed6")
sexcolors <- c("female" = "#969696", "male" = "#525252")
colorstissue <- c("hypothalamus" = "#d95f02",
                  "pituitary" = "#1b9e77",
                  "gonads" =  "#7570b3")
allcolors <- c(colorschar, sexcolors, colorstissue)