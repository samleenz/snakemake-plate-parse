# 2017-12-18
# Author: Sam Lee
# Data analysis pipeline  for Aiden
# Processing of Envision plate reader files
# If used for publications, proper attribution should
# be given :~)

# Set the file names for plates and plate pairs in
# the config.yaml file

configfile: "config.yaml"

from os.path import join
import re

### FUNCTIONS

# merge multiple summary files to one. 
def get_summarys(wildcards):
    files = glob_wildcards("results")


### RULES

# pseudorule to generate all files.
rule all:
    input:
        "results/summary.txt"

# collate summary files
# Then sort the file by number of hits
rule collate_summaries:
    input:
        main=expand("results/{pair}_summary.txt", pair=config["pairs"].values())
    output:
        "results/summary.txt"
    shell:
        """
        cat {input.main} > results/summary.txt
        sort -r -k 3,3 -o results/summary.txt results/summary.txt
        """
    
# create temp files with number of hits per pair
rule summarise:
    input:
        # main=expand("results/z-score/{sample}_zscore.txt", sample=config["samples"])
        # main=expand("results/paired-hits/{pair}_paired_neg_hits.txt", pair=config["pairs"].values())
        main="results/paired-hits/{pair}_paired_pos_hits.txt"
    output:
        temp("results/{pair}_summary.txt")
    shell:
        """
        hits=`wc -l < {input.main}`
        echo "{wildcards.pair} : ${{hits}}" >> results/{wildcards.pair}_summary.txt
        """


rule make_delta:
    input:
        "data/{sample}.txt"
    output:
        "results/deltas/{sample}_delta.txt"
    # conda:
        # "envs/environment.yaml"
    shell:
        """
        Rscript code/create_deltas.R $(pwd) {input}
        """

rule z_score:
    input:
        "results/deltas/{sample}_delta.txt"
    output:
        a="results/z-score/{sample}_zscore.txt",
        b="results/z-score/plots/{sample}_zscore.png"
    # conda:
        # "envs/environment.yaml"
    shell:
        """
        Rscript code/convert_delta_z_score.R $(pwd) {input}
        """

rule match_plates:
    input:
        # this uses wildcard matching from the rule all input
        pair1="results/z-score/{pair1}_zscore.txt",
        pair2="results/z-score/{pair2}_zscore.txt"
    output:
        "results/paired-hits/{pair1}___{pair2}_paired_pos_hits.txt"
    # conda:
        # "envs/environment.yaml"
    shell:
        """
        Rscript code/compare_sister_plates.R $(pwd) {input.pair1} {input.pair2}
        """


