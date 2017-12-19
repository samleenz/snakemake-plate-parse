# 2017-12-05
# Author: Sam Lee
# Data analysis script for Aiden
# Import of Envision plate reader files
# 
# Arguemtns
# 1: topDir, data the en "/data" and results go into "results/deltas"
# 2: fName, name of the plateReader file to be analysed


# packages used -----------------------------------------------------------

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(stringr))


# Variables ---------------------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)

topDir <- args[1]
fName <- args[2]
# test val
# topDir <- "/Users/slee_imac/Dini-Aidan-EnvisionDataFiles"
# fName <- "SCW0137251_084229_003.txt"


# read in a plate file ----------------------------------------------------

plateRaw <- read_tsv(file.path(topDir, fName), skip = 1, n_max = 16)

rowNames <- pull(plateRaw, `X1`)

if(ncol(plateRaw) == 26){
  plateRaw <- dplyr::select(plateRaw, -c(`X1`, `X26`))
}

# calculate the control mean ----------------------------------------------

# one or two control cols?
# ctrlMean <- mean(c(pull(plateRaw, `24`), pull(plateRaw, `23`)))
ctrlMean <- mean(c(pull(plateRaw, `24`), pull(plateRaw, `23`)))



# create delta table ------------------------------------------------------

plateDelta <- plateRaw %>% mutate_all(funs( . - ctrlMean))


# save delta table --------------------------------------------------------

# add the row names back
plateDelta <- cbind(rowNames, plateDelta)

# remove the dir from fileame
outName <- str_replace(fName, "data/", "")

# save it
write_tsv(plateDelta, file.path(topDir, "results", "deltas", str_replace(outName, ".txt", "_delta.txt") ))