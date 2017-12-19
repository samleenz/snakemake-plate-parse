# 2017-12-15
# Author: Sam Lee
# Data analysis script for Aiden
# ranking of plate delta files
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
fName <- args[2]
# test val
# topDir <- "~/Dini-Aidan-EnvisionDataFiles"
# fName <- "results/deltas/SCW0137251_084229_003_delta.txt"


# make save dirs if needed

if (! dir.exists(file.path(topDir, "results", "z-score", "plots"))){
  dir.create(file.path(topDir, "results", "z-score", "plots"), recursive = T)
}

# read in a delta file ----------------------------------------------------

# deltaRaw <- as.matrix(read_tsv(file.path(topDir, "results", "deltas", fName))[, -1])
deltaRaw <- as.matrix(read_tsv(file.path(topDir, fName))[, -1])


# remove control lanes ----------------------------------------------------

# columns 1, 2, 23, 24

deltaDat <- deltaRaw[, -c(1, 2, 23, 24)]

# conversion and ranking --------------------------------------------------

# goes in a row-wise manner, i.e. 
#   deltaV[1:20] == deltaRaw[1, ]
deltaV <- as.vector(t(deltaDat))

# add plate coordinates
# there are 320 wells when cols 1,2,23,24 are removed
# so 64 wells removed
# the naming vector is thus:

plateNum <- c(
  3:22,
  27:46,
  51:70,
  75:94,
  99:118,
  123:142,
  147:166,
  171:190,
  195:214,
  219:238,
  243:262,
  267:286,
  291:310,
  315:334,
  339:358,
  363:382
)

names(deltaV) <- plateNum

zscoreV <- as.vector(scale(deltaV))
names(zscoreV) <- plateNum

zscoreV <- zscoreV[rev(order(zscoreV))]

# save ranked z-scores, with plate location -------------------------------

outName <- str_replace(fName, "results/deltas/", "")

zscoreDF <- cbind(names(zscoreV), zscoreV)
colnames(zscoreDF) <- c("plateCoordinate", "zScore")

write_tsv(as.data.frame(zscoreDF), file.path(topDir, "results", "z-score", str_replace(outName, "delta.txt", "zscore.txt") ))


# make and save curve plot of z-scores ------------------------------------

zscoreG <- qplot(y = rev(zscoreV), x = 1:length(zscoreV), geom = "point") +
  labs(x = "Rank", y= "z-score") +
  ggtitle(str_replace_all(str_replace(outName, "delta.txt", ""), "_", " "), subtitle = "Sam Lee")


ggsave(file.path(topDir, "results", "z-score", "plots", str_replace(outName, "delta.txt", "zscore.png") ))
# png(filename = file.path(topDir, "results", "z-score", "plots", str_replace(fName, "delta.txt", "zscore.png")))
# plot(zscoreV)
# dev.off()
