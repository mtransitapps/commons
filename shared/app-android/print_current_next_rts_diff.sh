#!/bin/bash
source ../commons/commons.sh

OPT="-u --color";

echo "==========";
echo "ROUTES:";
diff $OPT src/main/res-*/raw/*_gtfs_rts_routes;
echo "==========";
echo "TRIPS:";
diff $OPT src/main/res-*/raw/*_gtfs_rts_trips;
echo "==========";
echo "STOPS:";
diff $OPT src/main/res-*/raw/*_gtfs_rts_stops;
echo "==========";