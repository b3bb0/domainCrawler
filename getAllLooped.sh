#!/bin/bash

echo "should be running like: nohup ./getAllLooped.sh > getAll.log &"

while true; do
	./getRbotos.sh && break;
	sleep 3;
done
