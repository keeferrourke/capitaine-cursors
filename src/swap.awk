#!/usr/bin/awk -f

{
	while (match($0, /fill:#1a1a1a|fill:#ffffff/)) {
		printf "%s", substr($0,1, RSTART-1);
		$0 = substr($0, RSTART);
		printf "%s", /^fill:#1a1a1a/ ? "fill:#ffffff" : "fill:#1a1a1a";
		$0 = substr($0, 1+RLENGTH)
	}
	print
}
