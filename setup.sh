#!/bin/sh

if [ "$1" = "" ]; then
	echo ""
	echo "Yo!"
	echo " First thing go to https://index.commoncrawl.org/collinfo.json"
	echo " and pick an index you want to download, eg: CC-MAIN-2022-49"
	echo " than re-run it with: ./$0 CC-MAIN-YYYY-ID"
	echo "    eg: ./$0 CC-MAIN-2022-49"
	echo ""
	exit 1
fi

echo ""
echo "Cool, we are gonna get $1 domains"
echo ""

mkdir -p ./data
mkdir -p ./robots

read -p "Which country are you looking for? [2 character code] " country
echo -n $country | tr '[:upper:]' '[:lower:]' > ./data/.country

read -p "   what's the country domain? (eg: .uk) " domain
echo -n $domain | tr '[:upper:]' '[:lower:]' > ./data/.domain

COUNTRY=$(cat ./data/.country)

curl -s -O https://data.commoncrawl.org/crawl-data/$1/robotstxt.paths.gz
gunzip robotstxt.paths.gz
cat robotstxt.paths|cut -d '/' -f 1,2,3,4,5|uniq > ./data/.robots.paths
touch ./data/.robots.paths.done
echo '' > ./data/robots-XX.merged.$COUNTRY
rm -f robotstxt.paths


if [ ! -f ./data/robots-XX.merged.$COUNTRY ]; then
	touch ./data/robots-XX.merged.$COUNTRY
fi

mv setup.sh tools/
