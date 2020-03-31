BEGIN {
	FPAT = "([^,]+)|(\"[^\"]+\")"
	RS = "\r\n|\n|\r"
}

NF {
	if (substr($stopCode, 1, 1) == "\"") {
		len = length($stopCode)
		$stopCode = substr($stopCode, 2, len - 2) # get text within the 2 "
	}
	if ($stopCode == "\\") {
		$stopCode = "\\\\"
	}
	if (substr($stopId, 1, 1) == "\"") {
		len = length($stopId)
		$stopId = substr($stopId, 2, len - 2)  # get text within the 2 "
	}
	if (substr($stopName, 1, 1) == "\"") {
		len = length($stopName)
		$stopName = substr($stopName, 2, len - 2) # get text within the 2 "
	}
	print("		allStops.put(\"" $stopCode "\", \"" $stopId"\"); // " $stopName)
}
