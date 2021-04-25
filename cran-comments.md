## Test Environments

### r-hub

* Windows Server 2008 R2 SP1, R-release, 32/64 bit 
* Ubuntu Linux 20.04.1 LTS, R-release, GCC
* macOS 10.13.6 High Sierra, R-release, CRAN's setup

### rocker

* Ubuntu 20.04.2 LTS, R-devel

### Winbuilder

* R version 4.1.0 alpha (2021-04-22 r80209)

## R CMD check results

0 errors | 0 warnings | 2 notes

Notes:

1. New submission, possible mispelled package names in description (dplyr, ggplot)

The names are not mispelled.

2.  Found the following assignments to the global environment:
    File 'breakerofchains/R/chain_break.R':
    assign(".chain", .chain, .GlobalEnv)

This is a documented feature providing a facility analogous to `.Last.value`. It can be disabled with an option.

## Downstream dependencies

There are currently no downstream dependencies for this package.
