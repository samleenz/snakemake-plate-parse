# 2017-12-15
# Author: Sam Lee
# Data analysis script for Aiden
# combine sister plate files and identify coordinates 
# with z-score < -2 in both plates
# and conversion to z-score
# 
# Arguemtns
# 1: topDir, data the en "/data" and results go into "results/z-score"
# 2: fName, name of the delta file to be analysed

# packages used -----------------------------------------------------------

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(stringr))


# Variables ---------------------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)

topDir <- args[1]
fName1 <- args[2]
fName2 <- args[3]
# test val
# topDir <- "~/Dini-Aidan-EnvisionDataFiles"
# fName1 <- "results/z-score/SCW0137251_084229_003_zscore.txt"
# fName2 <- "results/z-score/SCW0137252_084229_002_zscore.txt"

# bare plate names
plate1 <- str_replace(basename(fName1), "_zscore.txt", "")
plate2 <- str_replace(basename(fName2), "_zscore.txt", "")

outName <- paste(plate1, plate2, sep = "___")

# make save dirs if needed

if (! dir.exists(file.path(topDir, "results", "paired-hits"))){
  dir.create(file.path(topDir, "results", "paired-hits"), recursive = T)
}


# cat("plate 1 is", plate1)
# cat("plate 2 is", plate2)


# Read in raw plates ------------------------------------------------------

plate1Raw <- read_tsv(file.path(topDir, fName1))
plate2Raw <- read_tsv(file.path(topDir, fName2))



# filter for negative hits ------------------------------------------------

plate1Neg <- plate1Raw %>% 
  filter(zScore < -2) %>% 
  pull(plateCoordinate)

plate2Neg <- plate2Raw %>% 
  filter(zScore < -2) %>% 
  pull(plateCoordinate)

combineNeg <- intersect(plate1Neg, plate2Neg)


# filter for pos hits -----------------------------------------------------

plate1Pos <- plate1Raw %>% 
  filter(zScore > 2) %>% 
  pull(plateCoordinate)

plate2Pos <- plate2Raw %>% 
  filter(zScore > 2) %>% 
  pull(plateCoordinate)

combinePos <- intersect(plate1Pos, plate2Pos)


# convert to plate coordinates --------------------------------------------

# ask sven how this works
# he is smart :~)
# but letN is row number of the well in 384 well format
# then it is used to get the column number
# NOTE: won't work if col 24 is a possible answer ¯\_(ツ)_/¯ 
coordNeg <- vector()
for (x in combineNeg){
  letN <- (floor(x / 24) + 1)
  num <- x - ((letN - 1) * 24)
  coordX <- paste0(LETTERS[letN], num)
  coordNeg <- c(coordNeg, coordX)
}

# save the hits -----------------------------------------------------------

# neg hits
write(coordNeg, file = file.path(topDir, "results", "paired-hits", paste0(outName, "_paired_neg_hits.txt")), ncolumns = 1)

# pos hits
# write(combinePos, file = file.path(topDir, "results", "paired-hits", paste0(outName, "_paired_pos_hits.txt")), ncolumns = 1)
