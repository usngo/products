#!/bin/bash
#
# This script count the number of publications between YYYY-MM and YYYY-MM
# that contain at least one affiliation from the the variable $partner
#
# This script uses standard bash commands and also the "jq" and "gsed" commands 
# to process the JSON files generated by the ADS-API
#
# usage:   ./count_papers.sh PARTNER YYYY-MM YYYY-MM
# example: ./count_papers.sh USA 2020-01 2020-06
#
# BEFORE RUNNING: create an ADS account and sign in:
#                 https://ui.adsabs.harvard.edu/user/account/login
#                 go to "account" -> "settings" -> "API Token"
#                 copy the value and paste below on the "token variable"
#
# AUTHOR: Vinicius Placco (vinicius.placco@noirlab.edu) - US NGO
#
# DATE OF THIS VERSION: 2021-05-08
#
# TODO: Test script on MAC and Linux machines. Make it agnostic?
# TODO: Check whether all command-line tools are in the $PATH
#
#############################################################################
# Add $token variable below before running the script. You can hardcode the
# partner, datei, and datef variables here as well, then run the script 
# without arguments.

token=
partner=$1
datei=$2
datef=$3

#############################################################################
# Check if token is present and at least one argument


if [ -z $token ] ; then
    echo "==================================================="
    echo "no ADS-API token provided, I am out..."
    echo "GETTING A TOKEN: create an ADS account and sign in:"
    echo "https://ui.adsabs.harvard.edu/user/account/login"
    echo "go to account -> settings -> API Token"
    echo "copy the value to the 'token' variable below"
    echo "==================================================="
    exit
fi

if [ "$#" -ne 3 ] ; then
    echo "==================================================="
    echo "illegal number of input parameters, I am out..."
    echo "example: ./count_papers.sh USA 2020-01 2020-06"
    echo "==================================================="
    exit
fi

#############################################################################
# The first query uses the "search" API and gathers the bibcode of the papers
# for further processing. The search includes the Gemini bibgroup and refereed
# papers from the astronomy database. The resulting JSON file is then processed
# to get the bibcodes.

curl -s -H "Authorization: Bearer $token" \
"https://api.adsabs.harvard.edu/v1/search/query?q=\
\
aff:"$partner"%20\
bibgroup:gemini%20\
pubdate:%5B"$datei"%20TO%20"$datef"%5D&\
fq=property:refereed&\
fq=database:astronomy&\
sort=date%20desc&\
rows=10000&\
fl=date,bibcode,aff,author,pub,citation_count,volume,page,title\
" | jq > full.json 

jq '.response .docs | .[] .bibcode' full.json | tr -s '\n' ',' | sed -e 's=,$==g' > bibcode.list

#############################################################################
# This query uses the export/ads API to get further information for the bibcode
# list generated above. The papers.txt formatting is suitable to publish on
# Twitter for example.

curl -s -H "Authorization: Bearer $token" -H "Content-Type: application/json" \
    https://api.adsabs.harvard.edu/v1/export/ads \
    -X POST \
    -d '{"bibcode": ['$(cat bibcode.list)']}' | jq > adsbib.json

jq .export adsbib.json | sed -e 's=\\n=|=g;s="==g' | tr '|' '\n' | 
    egrep -i '^%T|^%A|^%J|^%D|^%U' | gsed  's/^%T/\n&/g' | 
    gsed -z 's/\n%D/ -/g' | awk '{print substr($0,4,200)}' > papers.txt

#############################################################################
# This query uses the export/bibtex API to generate a complete bibTeX file that
# can be compiled to provide a pdf report of all the publications.

curl -s -H "Authorization: Bearer $token" -H "Content-Type: application/json" \
    https://api.adsabs.harvard.edu/v1/export/bibtex \
    -X POST \
    -d '{"bibcode": ['$(cat bibcode.list)']}' | jq > bibtex.json

jq .export bibtex.json | sed -e 's=^"@=@=g;s="$==g;s=\\n=|=g' | tr '|' '\n' |
                  sed -e 's=\\\\=\\=g;s=\\"{="{=g;s=}\\"=}"=g;s=\\\\"=\\"=g' > papers.bib

#############################################################################
# This query uses the metrics API to gather statistics on citations and other
# relevant publication metrics. The JSON file also contains information that can
# be used to generate histograms per year if and many other capabilities.

curl -s -H "Authorization: Bearer $token" -H "Content-Type: application/json" \
    https://api.adsabs.harvard.edu/v1/metrics \
    -X POST \
    -d '{"bibcodes": ['$(cat bibcode.list)']}' | jq > metrics.json

#############################################################################
# The variables below retrieve selected metrics from the JSON file and print
# them in the screen, along with other information provided from the variables.

echo "
======================================
Metrics for $partner ($datei - $datef)
======================================
number of papers   $(jq '."basic stats"."number of papers"' metrics.json)
total citations    $(jq '."citation stats refereed"."total number of citations"' metrics.json)
h-index            $(jq '."indicators"."h"' metrics.json)
i-10 index         $(jq '."indicators"."i10"' metrics.json)
i-100 index        $(jq '."indicators"."i100"' metrics.json)
======================================
" | tee summary.txt
#exit

#############################################################################
# The section below is optional. It takes the bibTeX file generated above,
# creates a LaTeX file, compiles it with pdflatex and bibtex, and creates a
# final pdf report with all the papers and the metrics shown above. To run this
# module, just remove the "exit" command above

echo "\
\documentclass[twocolumn,linenumbers]{aastex631}
\usepackage{hyperref}

\begin{document}

\title{Publication list based on Gemini Observatory data for Partner $partner}

\begin{abstract}

(\texttt{affiliation $partner} means that at least one author in the paper has an affiliation from $partner)

\end{abstract}

\section*{Search criteria on ADS}

\begin{verbatim}

  affiliation        $partner
  bibgroup           gemini
  database           astronomy
  date range         $datei - $datef
  property           refereed

\end{verbatim}

\vspace{3.0cm}

\section*{Metrics summary}

\begin{verbatim}

  number of papers   $(jq '."basic stats"."number of papers"' metrics.json)
  total citations    $(jq '."citation stats refereed"."total number of citations"' metrics.json)
  h-index            $(jq '."indicators"."h"' metrics.json)
  i-10 index         $(jq '."indicators"."i10"' metrics.json)
  i-100 index        $(jq '."indicators"."i100"' metrics.json)

\end{verbatim}

\nocite{*}
\bibliographystyle{aasjournal}
\bibliography{papers.bib}
\end{document}
" > bib.tex

echo -n "Generating LaTeX report..."
pdflatex bib 1> /dev/null
echo -n .
pdflatex bib 1> /dev/null
echo -n .
bibtex   bib 1> /dev/null
echo -n .
bibtex   bib 1> /dev/null
echo -n .
bibtex   bib 1> /dev/null
echo -n .
pdflatex bib 1> /dev/null
echo -n .
pdflatex bib 1> /dev/null
echo -n .
echo "done!"
echo

rm bib.[abdlro]*
#rm adsbib.json bib* full.json metrics.json papers.*

#############################################################################
