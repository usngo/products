---
## ads-api (`count_papers.sh`)

This script uses a series of APIs from [@adsabs](https://github.com/adsabs), described in https://github.com/adsabs/adsabs-dev-api.

### Disclaimer 

This script is provided "as-is". It has been tested on a MAC terminal, so if you are on a Linux machine there are some adjustments to be made. One of the items in the to-do list (see below) is to make this script *OS agnostic*.

---
### Command-line tools used by this script

    curl, jq, tr, sed, egrep, gsed, awk, tee, pdflatex, bibtex

The command `gsed` is the GNU version of `sed` (to work on a MAC machine), install via homebrew with:

    brew install gnu-sed

---
### Tentative to-do list:

- [x] Add an `if` statement at the beginning testing whether 3 input arguments are given
- [ ] Test script on MAC and Linux machines. Make it agnostic?
- [ ] Check whether all command-line tools are in the $PATH

---
Follow us on Twitter! <a href="https://twitter.com/usngo" target="_blank"><img src="https://badgen.net/twitter/follow/usngo"></a>
---
