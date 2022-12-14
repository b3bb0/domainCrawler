# domainCrawler
crawler to get list of active domains based on commoncrawl


first setup running:
	./setup.sh


then can run it in loop to fetch everything using:
	nohup while true; do ./getRbotos.sh && break; sleep 3; done > fetch-all.log
