#!/bin/bash

START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
echo "Started : $START_TIME"

psql -d warehouselive -h 10.199.52.194 -p 5432  -U marall



FINISH_TIME=$(date +"%Y-%m-%d %H:%M:%S")
echo "Finished : $FINISH_TIME"

