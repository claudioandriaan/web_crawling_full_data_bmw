BEGIN {nb_annonce=0}
/"pagination":{"/ {
	split($0, ar, /"items":/)
	split(ar[2], ar1, /,/)
	gsub("\r", "", ar1[1])
	gsub("[^0-9]", "", ar1[1])
	nb_annonce=ar1[1]
}

/"pagination":{"/ {
	split($0, ar, /"total"/)
	split(ar[2], ar1, /,/)
	    gsub("\r", "", ar1[1])
        gsub("[^0-9]", "", ar1[1])
        max_page=ar1[1]
}

END{
        print "nb_annonce="nb_annonce"; max_page="max_page";"
}