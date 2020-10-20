# attributes to load everywhere

## levels

charlevels <- c(
  "control", "bldg",
  "lay", "inc.d3", "inc.d9", "inc.d17",
  "hatch", "n5", "n9"
)

charlabels <- c(
  "control", "nest\nbuilding\n(bldg)",
  "1st egg\nlaid\n(lay)", "incubation\nday3\n(inc.d3)", 
  "incubation\nday9\n(inc.d9)", "incubation\nday17\n(inc.d17)",
  "2nd chick\nhatched\n(hatch)", "nestling\ncare day 5\n(n5)", 
  "nestling\ncare day 9\n(n9)"
)

maniplevels <- c("m.inc.d3" ,  "early" ,  "m.inc.d9" , "m.inc.d17", "prolong" ,  "m.n2", "extend")

alllevels <- c("control", "bldg", "lay", "inc.d3", "m.inc.d3" ,  
               "inc.d9", "m.inc.d9" , "early" ,
               "inc.d17",  "m.inc.d17", "prolong", 
               "hatch",  "m.n2", "extend",
               "n5",  
               "n9")

sexlevels <- c("female", "male")

tissuelevel <- c("hypothalamus", "pituitary", "gonad")
tissuelevels <- c("hypothalamus", "pituitary", "gonads")

comparisonlevels <- c(
  "control_bldg", "bldg_lay", "lay_inc.d3",
  "inc.d3_inc.d9", "inc.d9_inc.d17", "inc.d17_hatch",
  "hatch_n5", "n5_n9"
)


## colors

colorschar <- c(
  "control" = "#cc4c02",
  "bldg" = "#fe9929",
  "lay" = "#fed98e",
  "inc.d3" = "#78c679",
  "inc.d9" = "#31a354",
  "inc.d17" = "#006837",
  "hatch" = "#08519c",
  "n5" = "#3182bd",
  "n9" = "#6baed6"
)

colorsmanip <- c("m.inc.d3" = "#CDCDCD", 
                 "m.inc.d9" = "#959595", 
                 "m.inc.d17" = "#626262",
                 "m.n2" = "#262625", 
                 "early" = "#cbc9e2", 
                 "prolong" = "#9e9ac8" , 
                 "extend" = "#6a51a3" )

colorssex <- c("female" = "#969696", "male" = "#525252")

colorstissue <- c(
  "hypothalamus" = "#d95f02",
  "pituitary" = "#1b9e77",
  "gonads" = "#7570b3",
  "gonad" = "#7570b3"
)

allcolors <- c(colorschar, colorsmanip, colorssex, colorstissue)