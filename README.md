# domainCrawler
crawler to get list of active domains based on commoncrawl


First setup running: `./setup.sh`.
Once it's configure I suggest you do a test run using: `./getRbotos.sh`


if all semms good you can run:
```bash
nohup while true; do ./getRbotos.sh && break; sleep 3; done > fetch-all.log
```

And go check the day after in ``data/``
