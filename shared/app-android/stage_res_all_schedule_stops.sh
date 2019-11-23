#!/bin/bash
source ../commons/commons.sh

./stage_res_current_schedule_stops.sh;
checkResult $?;

./stage_res_next_schedule_stops.sh;
checkResult $?;
