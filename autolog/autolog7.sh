#!/bin/bash

tday=$(gdate +"%Y-%m-%d")
obsd=$(gdate -d ''$tday'' +'%Y%m%d')
yday=$(gdate -d ''$tday' 1 day ago' +'%m/%d/%y')

gems=http://www.gemini.edu/sciops/schedules/schedQueue_GS_2021A.html
gemn=http://www.gemini.edu/sciops/schedules/schedQueue_GN_2021A.html

prog=US
sem=2021A

if grep -q $obsd <(curl -s $gems | html2text -width 450 -ascii | grep -A 2 'GS-'$sem'-Q.*'$prog'') ||
   grep -q $obsd <(curl -s $gemn | html2text -width 450 -ascii | grep -A 2 'GN-'$sem'-Q.*'$prog''); then

echo "$prog programs observed at Gemini on $yday (http://bit.ly/2KhLox3):
------------------
Program ID (% complete)
------------------" > G${tday}_log.txt

curl -s $gems | html2text -width 450 -ascii | grep -B 2 $obsd | grep -A 2 'GS-'$sem'-Q.*'$prog'' | 
                tr -s '\n' ',' | sed -e 's=,--,=|=g' | tr -s '|' '\n' | tr -s ' ' ' ' | 
                sed -e 's=,==g' | awk '{printf("%s (%s)\n",$1,$NF)}' >> G${tday}_log.txt

curl -s $gemn | html2text -width 450 -ascii | grep -B 2 $obsd | grep -A 2 'GN-'$sem'-Q.*'$prog'' | 
                tr -s '\n' ',' | sed -e 's=,--,=|=g' | tr -s '|' '\n' | tr -s ' ' ' ' | 
                sed -e 's=,==g' | awk '{printf("%s (%s)\n",$1,$NF)}' >> G${tday}_log.txt

grep ^G G${tday}_log.txt | sed -e 's=(==g;s=%)==g' | sort | sort -n -k 2 | 
     awk '{if($2<=30)
	       pct=30
           else
	       pct=$2
           printf("%02d,%s,%d,%d%,%d\n",NR-1,$1,$2,$2,pct)}' > G${tday}_log.plt

nprog=$(wc -l < G${tday}_log.plt)

height=$(echo $nprog | awk '{
    if(($1*(500/6))<100)
	height=150
    else
	if(($1*(500/6))<=500)
	    height=($1*(500/6))
	else
	    height=500
    print height}')

gnuplot << GNUPLOT 2> /dev/null

set term png size 1000,$height font ",16"
set output "G${tday}_log.png"

set datafile separator ','
unset key
set format x '%g%%'
set format y ""
set style fill transparent solid 0.40 border

set xrange[0:102.5]
set yrange[-0.5:$nprog-0.5]
set xtics  10
set mxtics 4
unset ytics

set xlabel "$prog Program Completion"

plot "<grep GS G${tday}_log.plt" using (\$3*0.5):1:(\$3*0.5):(0.4):yticlabels(2) with boxxyerrorbars lt -1 lw 1 lc rgb "#500076B6",\
     "<grep GN G${tday}_log.plt" using (\$3*0.5):1:(\$3*0.5):(0.4):yticlabels(2) with boxxyerrorbars lt -1 lw 1 lc rgb "#50F15D5D",\
     "G${tday}_log.plt" using (\$5-0.75):1:4 with labels right notitle,\
     "G${tday}_log.plt" using (2):1:2 with labels left notitle

GNUPLOT

#cd ~/codes/tweet.sh
#
#./tweet.sh upload $HOME/noirlab/usngo/autolog/v7/G${tday}_log.png > tmp_GS
#
#taggs=$(cat tmp_GS | jq '.media_id_string' | head -1 | sed -e 's="==g')
#
#./tweet.sh tw -m $taggs US programs observed at \@GeminiObs N/S on $yday \(http://bit.ly/2KhLox3\):
#
#rm tmp_G[SN]

else

    echo "No programs from $prog observed on $obsd"

fi
