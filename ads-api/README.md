---
# ads-api (`count_papers.sh`)

This script uses a series of APIs from @adsabs, described in https://github.com/adsabs/adsabs-dev-api.

## Disclaimer 

This script is provided "as-is". It has been tested on a MAC terminal, so if you are on a Linux machine there are some adjustments to be made. One of the items in the to-do list (see below) is to make this script *OS agnostic*.

---
## Command-line tools used by this script

    curl, jq, tr, sed, egrep, gsed, awk, tee, pdflatex, bibtex

The command `gsed` is the GNU version of `sed` (to work on a MAC machine), install via homebrew with:

    brew install gnu-sed

---
## Tentative to-do list:

- [x] Add an `if` statement at the beginning testing whether 3 input arguments are given
- [ ] Test script on MAC and Linux machines. Make it agnostic?
- [ ] Check whether all command-line tools are in the $PATH

---
## Need help?

Problems, comments, suggestions, and/or need help with setting up and running the Jupyter notebooks? You can contact the US NGO members via our [Portal](http://ast.noao.edu/csdc/usngo), [Twitter](https://twitter.com/usngo), or submit a *New issue* through github.

For assistance with DRAGONS installation and procedures, please submit a ticket to the [Gemini Helpdesk](https://www.gemini.edu/observing/helpdesk/submit-general-helpdesk-request) (Partner Country: US; Topic: DRAGONS).

Follow us on Twitter! <a href="https://twitter.com/usngo" target="_blank"><img src="https://badgen.net/twitter/follow/usngo"></a>

---
