---
## ads-api (`count_papers.sh`)

This script uses a series of APIs from [@adsabs](https://github.com/adsabs), described in https://github.com/adsabs/adsabs-dev-api.

---
### Disclaimer 

This script is provided "as-is". It has been tested on a MAC terminal (using `/bin/bash`), so if you are on a Linux machine there are some adjustments to be made. One of the items in the to-do list (see below) is to make this script *OS agnostic*.

---
### Command-line tools used by this script

    curl, jq, tr, sed, egrep, gsed, awk, tee, pdflatex, bibtex

The command `gsed` is the GNU version of `sed` (to work on a MAC machine), install via homebrew with:

    brew install gnu-sed

Also, there are two auxiliary files (`aasjournal.bst` and `aastex63.cls`) that are needed to generate the LaTeX output file.

---
### Before running the script: get an `ADS-API` token:

- Create an ADS account and/or sign in: https://ui.adsabs.harvard.edu/user/account/login
- Go to "acccount" -> "settings" -> "API Token"
- Copy the value and paste it on the `token` variable inside the script (line 29) 

---
### Running the script

On your `bash` terminal:

    [user@host]$ ./count_papers.sh PARTNER YYYY-MM YYYY-MM

The first parameter (`PARTNER`) has to do with the affiliations in the author list, so it is pretty flexible. I've tested with all Gemini Partners and it worked. The second and third parameter set the date range (with the `YYYY-MM` format) for the search.

---
### Output files (in progress...)

- adsbib.json
- bib.pdf
- bib.tex
- bibcode.list
- bibtex.json
- full.json
- metrics.json
- papers.bib
- papers.txt
- summary.txt

---
### Tentative to-do list:

- [x] Add an `if` statement at the beginning testing whether 3 input arguments are given
- [ ] Test script on MAC and Linux machines. Make it agnostic?
- [ ] Check whether all command-line tools are in the $PATH

---
