#!/bin/bash
source ../commons/commons.sh

OPT="-u --color";

echo "==========";
echo "ROUTES:";
diff $OPT src/main/res-*/raw/*_gtfs_rts_routes; # do not change to avoid breaking compat w/ old modules
echo "==========";
echo "DIRECTIONS:";
diff $OPT src/main/res-*/raw/*_gtfs_rts_trips; # do not change to avoid breaking compat w/ old modules
echo "==========";
echo "STOPS:";
diff $OPT src/main/res-*/raw/*_gtfs_rts_stops; # do not change to avoid breaking compat w/ old modules
echo "==========";