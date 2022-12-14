#!/bin/bash

# # setup
#curl -O https://data.commoncrawl.org/crawl-data/CC-MAIN-2022-40/robotstxt.paths.gz
#gunzip robotstxt.paths.gz
#cat robotstxt.paths|cut -d '/' -f 1,2,3,4,5|uniq > data/.robots.paths
#rm -f robotstxt.paths
#echo '' > data/robots-XX.merged.au
#rm -f data/.merged.au.tmp

if [ ! -f ./data/.robots.paths ]; then
	echo ""
	echo " Please run setup.sh first"
	exit 0;
fi

BIT=$(comm -23 ./data/.robots.paths ./data/.robots.paths.done|head -n 1)

if [ "$BIT" = "" ]; then
	echo "ALL PARSED!";
	exit 0;
fi

echo "1) Synching $BIT from bucket"

cd robots
aws s3 sync s3://commoncrawl/$BIT . --quiet
if [ "$?" != "0" ]; then
	echo "some files are missing, retry in few minutes"
	exit 0;
fi
gunzip *
cd ..

echo $BIT >>  ./data/.robots.paths.done
ROBONUM="-"$(wc -l ./data/.robots.paths.done|cut -d ' ' -f 1)

echo "2) Parsing commocrawl file for index $ROBONUM"

find ./robots/ -type f | while read file; do
	grep -B 1 'WARC-Target-URI' $file 2>/dev/null | grep ':' |awk '{print $2}'|sed "N;s/\r\n/ /" >> data/robots$ROBONUM.join
done

echo "3) Joining and getting IP locations "
if [ ! -f data/robots-XX.merged ]; then
	touch data/robots-XX.merged
fi

node parseRobots.js data/robots$ROBONUM.join | sort | uniq > data/robots$ROBONUM.country
comm -23 data/robots$ROBONUM.country data/robots-XX.merged > data/.merged.tmp
REALADD=$(wc -l data/.merged.tmp)
cat data/.merged | sort | uniq > data/robots-XX.merged

if [ -f ./data/.country ]; then
	COUNTRY=$(cat ./data/.country)
	grep -i "$COUNTRY" data/robots$ROBONUM.country |cut -d ' ' -f 2|sort |uniq > data/robots$ROBONUM.country.$COUNTRY
	DOMAIN=$(cat ./data/.domain)
	if [ "$COUNTRY" != "$DOMAIN" ]; then
		grep -i "$DOMAIN " data/robots$ROBONUM.country |cut -d ' ' -f 2|sort |uniq >> data/robots$ROBONUM.country.$COUNTRY
		mv data/robots$ROBONUM.country.$COUNTRY data/robots$ROBONUM.country.$COUNTRY.tmp
		cat data/robots$ROBONUM.country.$COUNTRY.tmp |sort | uniq > data/robots$ROBONUM.country.$COUNTRY
		rm -f data/robots$ROBONUM.country.$COUNTRY.tmp
	fi
	comm -23 data/robots$ROBONUM.country.$COUNTRY data/robots-XX.merged.$COUNTRY > data/.merged.$COUNTRY.tmp
	REALADD=$(wc -l data/.merged.$COUNTRY.tmp)
	cat data/.merged.$COUNTRY | sort | uniq > data/robots-XX.merged.$COUNTRY
	rm -f data/.merged.$COUNTRY.tmp
	echo "4) Added $REALADD new $COUNTRY domains to: data/robots-XX.merged.$COUNTRY "
fi

echo "4) Added $REALADD new domains to: data/robots-XX.merged "

rm -fR robots/*

exit 1;

