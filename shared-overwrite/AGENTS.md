# ORIGINAL FILE: https://github.com/mtransitapps/commons/tree/master/shared-overwrite

This repository is part of an Android project with multiple Android apps and JVM data parsers.

The main Android app has multiple Gradle modules organized around git submodules.

The pull requests and branches builds are run on all git submodules repositories code with the same branch name or the default branch names.

The main git repositories with business logic are:
- https://github.com/mtransitapps/mtransit-for-android/: the main Android app
- https://github.com/mtransitapps/commons-android/: the shared Android library code between the main Android app and the other "agency modules" apps
- https://github.com/mtransitapps/parser/: the JVM data parsing code for GTFS based "agency modules"
- https://github.com/mtransitapps/commons-java/: the shared JVM code
- https://github.com/mtransitapps/commons/: the shared shells and automatic code

Most other git repositories are "agency modules" that contains configuration and data for this transit agencies named like:
`xx-location-transit-agency-type-android` (like `ca-montreal-stm-bus-android`).

The main build file is:
- https://github.com/mtransitapps/mtransit-for-android/blob/master/.github/workflows/mt-build.yml
It's using:
- https://github.com/mtransitapps/gh-actions/blob/master/.github/actions/setup/action.yml
