BEGIN {
	FPAT = "([^\",]*)"
	RS = "\r\n|\n|\r"
}

NF {
	print("		allStops.put(\"" $stopCode "\", \"" $stopId"\"); // " $stopName)
}
