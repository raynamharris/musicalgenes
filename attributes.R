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

maniplevels <- c("m.inc.d3" ,  "early" ,  "m.inc.d9" ,
                 "m.inc.d17", "prolong" ,  "m.n2", "extend")

alllevels <- c("control", "bldg", "lay", "inc.d3", "m.inc.d3" ,  
               "inc.d9", "m.inc.d9" , "early" ,
               "inc.d17",  "m.inc.d17", "prolong", 
               "hatch",  "m.n2", "extend",
               "n5",  "n9")

rmlevels <- c("inc.d3" ,  "m.inc.d3" ,  "inc.d9" , "m.inc.d9", 
              "inc.d17", "m.inc.d17" ,  "hatch", "m.n2")

timelevels <- c("inc.d9", "early", 
                "inc.d17", "prolong",
                "hatch", "extend")

sexlevels <- c("female", "male")

tissuelevel <- c("hypothalamus", "pituitary", "gonad")
tissuelevels <- c("hypothalamus", "pituitary", "gonads")

comparisonlevels <- c(
  "control_bldg", "bldg_lay", "lay_inc.d3",
  "inc.d3_inc.d9", "inc.d9_inc.d17", "inc.d17_hatch",
  "hatch_n5", "n5_n9"
)

## R theme

musicalgenestheme <- function () { 
  theme_minimal(base_size = 16,
                base_family = 'Helvetica') +
    theme(
      panel.grid.major  = element_blank(),  # remove major gridlines
      panel.grid.minor  = element_blank()  # remove minor gridlines
    )
}


## colors



colorschar <-  c("control" = "#D2B48C", 
                 "bldg"= "#D2B48C", 
                 "lay"= "#ffffff", 
                 "inc.d3"= "#d07776", 
                 "inc.d9"= "#d07776", 
                 "inc.d17"= "#d07776", 
                 "hatch"= "#a991c7",
                 "n5"= "#a991c7", 
                 "n9"= "#a991c7" )

colorsmanip <- c("m.inc.d3" = "#373b42", 
                 "m.inc.d9" = "#373b42", 
                 "m.inc.d17" = "#373b42",
                 "m.n2" = "#373b42", 
                 "early" = "#f2cf0a", 
                 "prolong" = "#f2cf0a" , 
                 "extend" = "#f2cf0a" )

colorsstudy <- c("char" = "#737373", 
                 "manip" = "#252525")





colorssex <- c("female" = "#969696", "male" = "#525252")

colorstissue <- c(
  "hypothalamus" = "#d95f02",
  "pituitary" = "#1b9e77",
  "gonads" = "#7570b3",
  "gonad" = "#7570b3"
)

allcolors <- c(colorschar, colorsmanip, colorssex, colorstissue, colorsstudy)


## music notes and instruments

numberstonotes <- data.frame(
  scaledmean = c(0:6),
  note = c("A", "B",  "C",  "D", "E", "F",  "G")
)

orchestra <- c("violin", 
               "french horn", "clarinet", "bassoon", "oboe",
               "trumpet", "trombone", "tuba",
               "upright bass", "viola", "cello",
               "piano", "keyboard",
               "saxophone")

orchestra <- sort(orchestra)

