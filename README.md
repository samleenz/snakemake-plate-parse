# Envision Screen data cleaning

## Author: Sam Lee, `samleenz@me.com`
## Date: 2017-12-05

Initial parsing of Envision PlateReader files for Aidan.

### Directory strucutre

* `code/` has the scripts for processing
* `data/` contains raw data files
* `results/deltas` has the delta files for each plate in `/data`
* `results/z-score` has ranked z-score lists for each plate and a plot of the z-score distribution for each plate
* `results/paired-hits` are the lists of plate coordinates where `z-score < -2` for both duplicate plates
* `results/summary.txt` is the summary file for the pipeline. It lists each pair and the number of "hits" in descending order.

### Deltas

* Deltas (differences) are calcualted as the difference between every well *ij*, for *i* rows and *j* columns, and the arithmetic mean of column 23 and 24. 
* The filenames for the deltas match the raw filename but with the addition of `_delta` to the end of each file.

### Z-score

* The Z-score is a centred transformation of the delta values where they are moved from an absolute scale to the standard deviation scale
* columns [1,2,23,24] (controls) are removed prior to the z-score transformation so do not affect the distribution of the standard deviations
* The filenames for the z-scores match the raw filename but with the addition of `_zscore` to the end of each file.


## Configuring the Snakemake pipeline

To configure the pipeline for execution the plate name pairs must be specified in the `config.yaml` file as follows:

```
pairs:
    A: SCW0137251_084229_003___SCW0137252_084229_002
    B: SCW0137253_084229_001___SCW0137254_084229_004

```

The triple-underscore `___` betwen the plate names is important.

To test the pipeline once the config file is edited use

```
snakemake --dag --forceall | dot -Tpng > dag.png
#or
snakemake -npr
```

To execute:

```
snakemake
```

If further plate pairs are added only those that have not been run will be re-calculated if `snakemake` is called again.


### misc

To regenerate this readme from the markdown doc:

```
pandoc -s README.md -o README.html
```