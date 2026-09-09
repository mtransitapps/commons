# Producing useful obfuscated stack traces
# https://www.guardsquare.com/manual/configuration/examples#stacktrace
-renamesourcefileattribute SourceFile
-keepattributes LineNumberTable
-keepattributes SourceFile
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# '-dontobfuscate' blocks all obfuscation (0%) > Play Store NOT happy:
# "Improve your app's memory and performance with R8 optimization
# Your R8 configuration could be causing higher memory usage and lower performance.
# Address the following to improve your app's optimization:
# - Obfuscation isn't enabled.
# [Memory usage]"
# # Do not obfuscate the class files since open source & no Crashlytics
# -dontobfuscate
-keepnames class org.mtransit.android.** { *; }
