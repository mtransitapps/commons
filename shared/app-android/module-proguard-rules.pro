# Producing useful obfuscated stack traces
# https://www.guardsquare.com/manual/configuration/examples#stacktrace
-renamesourcefileattribute SourceFile
-keepattributes LineNumberTable
-keepattributes SourceFile
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Do not obfuscate the class files since open source & no Crashlytics
-dontobfuscate
