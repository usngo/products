#!/bin/bash

today=$(date +"%Y-%m-%d")
obsd=$(date +"%Y%m%d")
yday=$(date -v -1d +"%m/%d/%y")


gems=http://www.gemini.edu/sciops/schedules/schedQueue_GS_2021A.html
gemn=http://www.gemini.edu/sciops/schedules/schedQueue_GN_2021A.html

prog=US
sem=2021A

if grep -q $obsd <(curl -s $gems | html2text -width 450 -ascii | grep -A 2 'GS-'$sem'-Q.*'$prog'') ||
   grep -q $obsd <(curl -s $gemn | html2text -width 450 -ascii | grep -A 2 'GN-'$sem'-Q.*'$prog''); then

echo "$prog programs observed at Gemini on $yday (http://bit.ly/2KhLox3):
------------------
Program ID (% complete)
------------------" > G${today}_log.txt

curl -s $gems | html2text -width 450 -ascii | grep -B 2 $obsd | grep -A 2 'GS-'$sem'-Q.*'$prog'' | 
                tr -s '\n' ',' | sed -e 's=,--,=|=g' | tr -s '|' '\n' | tr -s ' ' ' ' |
                sed -e 's= \[r22A\]==g'  | sed -e 's=,Exec=|Exec=g' > tmp1

paste -d ' ' <(awk '{print $1}' tmp1) <(awk '{print $NF}' tmp1 | sed -e 's=,==g') \
             <(cut -d '|' -f1 tmp1 | awk '{print $(NF-1)}') <(cut -d '|' -f1 tmp1 | awk '{print $NF}') | 
	     awk '{printf("%s (%s) %s %s\n",$1,$2,$3,$4)}' >> G${today}_log.txt

curl -s $gemn | html2text -width 450 -ascii | grep -B 2 $obsd | grep -A 2 'GN-'$sem'-Q.*'$prog'' | 
                tr -s '\n' ',' | sed -e 's=,--,=|=g' | tr -s '|' '\n' | tr -s ' ' ' ' |
                sed -e 's= \[r22A\]==g'  | sed -e 's=,Exec=|Exec=g' > tmp2

paste -d ' ' <(awk '{print $1}' tmp2) <(awk '{print $NF}' tmp2 | sed -e 's=,==g') \
             <(cut -d '|' -f1 tmp2 | awk '{print $(NF-1)}') <(cut -d '|' -f1 tmp2 | awk '{print $NF}') | 
	     awk '{printf("%s (%s) %s %s\n",$1,$2,$3,$4)}' >> G${today}_log.txt

rm tmp[12]

grep ^G G${today}_log.txt | sed -e 's=(==g;s=%)==g;s=GMOS-S=GMOS=g' | sort | sort -n -k 2 | awk '{
    if($2<=45)
	pct=45
    else
	pct=$2
    printf("%02d,%s,%d,%d%,%d,(%s)\n",NR-1,$1,$2,$2,pct,$3)}' > G${today}_log.plt

nprog=$(wc -l < G${today}_log.plt)

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
set output "G${today}_log.png"

set datafile separator ','
unset key
set format x '%g%%'
set format y ""
set style fill transparent solid 0.40 border

set xrange[0:102.5]
set yrange[-$llim:$ulim]
set xtics  10
set mxtics 4
unset ytics


set xlabel "$prog Program Completion"

plot "<grep GS G${today}_log.plt" using (\$3*0.5):1:(\$3*0.5):(0.4):yticlabels(2) with boxxyerrorbars lt -1 lw 1 lc rgb "#500076B6",\
     "<grep GN G${today}_log.plt" using (\$3*0.5):1:(\$3*0.5):(0.4):yticlabels(2) with boxxyerrorbars lt -1 lw 1 lc rgb "#50F15D5D",\
     "G${today}_log.plt" using (\$5-0.75):1:4 with labels right notitle,\
     "G${today}_log.plt" using (2):1:2 with labels left notitle,\
     "G${today}_log.plt" using (21):1:6 with labels left notitle

GNUPLOT

IFS=

if [ -z $1 ]; then

curl --url 'smtps://smtp.gmail.com:465' --ssl-reqd -s \
     --mail-from 'Gemini Autolog' \
     --mail-rcpt 'recipient@gmail.com' \
     --user 'automatic@gmail.com:password' \
     -T <(echo -e 'From: Gemini Autolog\nTo: \nSubject: Gemini summary' $today '\n\n' $(cat G${today}_log.txt)) \

else

# get Twitter developer account from https://developer.twitter.com/en/apply-for-access
# using https://github.com/piroor/tweet.sh as API

cd /path/to/codes/tweet.sh

./tweet.sh upload /path/to/G${today}_log.png > tmp_GS

taggs=$(cat tmp_GS | jq '.media_id_string' | head -1 | sed -e 's="==g')

./tweet.sh tw -m $taggs US programs observed at \@GeminiObs N/S on $yday \(http://bit.ly/2KhLox3\):

rm tmp_G[SN]

fi

else
    echo no
fi

exit
