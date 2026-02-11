#!/bin/bash

function setFeatureFlags() {

  echo "> Feature flags:";

  F_EXPORT_VEHICLE_LOCATION_PROVIDER=false;
  # F_EXPORT_VEHICLE_LOCATION_PROVIDER=true; # WIP
  echo "> - F_EXPORT_VEHICLE_LOCATION_PROVIDER: '$F_EXPORT_VEHICLE_LOCATION_PROVIDER'.";

}
