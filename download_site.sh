#!/bin/bash

ExitProcess () {
        status=$1
        if [ ${status} -ne 0 ]
        then
                echo -e $usage
                echo -e $error
        fi
        find ${dir}/ -type f -name "*.$$" -exec rm -f {} \;
        exit ${status}
}

function download_pages () {
	# url
	# output 
	# refere 
	 curl "${url}" \
		  -H 'accept: application/json, text/plain, */*' \
		  -H 'accept-language: fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7' \
		  -H 'priority: u=1, i' \
		  -H "referer: ${refere}" \
		  -H 'sec-ch-ua: "Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"' \
		  -H 'sec-ch-ua-mobile: ?0' \
		  -H 'sec-ch-ua-platform: "Windows"' \
		  -H 'sec-fetch-dest: empty' \
		  -H 'sec-fetch-mode: cors' \
		  -H 'sec-fetch-site: same-origin' \
		  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36' \
		  -H 'x-csrftoken: Ad5Srw9f2NtyPfcmdkuVfXVGvlAjvUyDUoyUg2QdjVZiFwWBav5yN07lK4knJkbo' > ${output} 
		  
}

function download_list_multy_process (){
	rm -f  ${directory}/wget_file.txt
	nb_processus=10
	awk 'BEGIN{FS="\t"}{print "if [ ! -s "$1" ]; then url=\""$2"\"; output=\""$1"\"; refere=\""$3"\";  download_pages ; fi"}' ${list_file} > ${directory}/wget_file.txt
    nb=`wc -l ${directory}/wget_file.txt | awk '{print $1}' `
    let "split = (nb / nb_processus) + 1"
    split -l${split} -d ${directory}/wget_file.txt  ${directory}/wget_file.txt.
    i=0
    for wget_file in `ls ${directory}/wget_file.txt.*`
    do
        echo -e "set -x\n">>${wget_file}
        . ${wget_file} >  ${directory}/LOG/log_${i} 2>&1 &
        let "i=i+1"
    done
	wait 
}

#
# MAIN
#
usage="download_site.sh \n\
\t-a no download - just process what's in the directory\n\
\t-d [date] (default today)\n\
\t-h help\n\
\t-i id start de la region default : 1\n\
\t-I id end de la region default : max_region\n\
\t-M [region]\n\
\t-m [modele]\n\
\t-r retrieve only, do not download the detailed adds\n\
\t-R reset : delete files to redownload\n\
\t-t table name \n\
\t-T valeurs : new used certified ex: -T\"used new\"\n\
\t-x debug mode\n\
"

date
typeset -i lynx_ind=1
typeset -i get_detail_mod=1
typeset -i get_all_ind=1
typeset -i get_list_ind=1
typeset -i nb_retrieve_per_page=23
typeset -i max_retrieve=30000
typeset -i nb_processus=5
typeset -i max_loop_1=5
typeset -i max_loop=3
Y=`date "+%Y"  --date="-366 days ago"`

while getopts :-ad:rht:xz: name
do
  case $name in

    a)  lynx_ind=0
        let "shift=shift+1"
        ;;

    d)  d=$OPTARG
        let "shift=shift+1"
        ;;

        i)      MIN_REGION_ID=$OPTARG
        let "shift=shift+1"
        ;;

    I)  MAX_REGION_ID=$OPTARG
        let "shift=shift+1"
        ;;

    M)  my_region=`echo ${OPTARG} | tr '[:lower:]' '[:upper:]' `
        let "shift=shift+1"
        ;;

        m)      my_modele=`echo $OPTARG | tr '[:lower:]' '[:upper:]' `
        let "shift=shift+1"
        ;;

    h)  echo -e ${usage}
        ExitProcess 0
        ;;

    r)  get_all_ind=0
        let "shift=shift+1"
        ;;

    t)  table=$OPTARG
        let "shift=shift+1"
        ;;

    x)  set -x
        let "shift=shift+1"
        ;;

    z)  let "shift=shift+1"
        ;;

    --) break
        ;;

        esac
done
shift ${shift}

if [ $# -ne 0 ]
        then
    error="Bad arguments, $@"
    ExitProcess 1
fi

if [ "${d}X" = "X" ]
        then
        d=`date +"%Y%m%d"`
fi
if [ "${table}X" = "X" ]
        then
        mois=$(date --date "today + `date +%d`days" +%Y_%m)
        table="bmw"`date +"%Y_%m"`
fi
if [ "${grand_table}X" = "X" ]
        then
        grand_table="VO_UK_"`date +"%Y_%m"`
fi 

debut=`date +"%Y-%m-%d %H:%M:%S"`
dir=`pwd`
mkdir -p ${dir}/${d} ${dir}/${d}/LISTING ${dir}/${d}/ALL 
touch ${dir}/${d}/status 

if [ ${get_list_ind} -eq 1 ]; then
	
	echo  -e "list" > ${dir}/${d}/status 

	for serie in "BMWi" "1" "2" "3" "4" "5" "6" "7" "8" "M" "X" "Z" 
	do 
		mkdir -p ${dir}/${d}/LISTING/${serie} 
	
		if [[ ${serie} == "BMWi" ]]; then 
				url="https://usedcars.bmw.co.uk/vehicle/api/list/?page=1&series=BMWi&size=23"
				refere="https://usedcars.bmw.co.uk/result/?page=1&series=BMWi&size=23"
		else 
				url="https://usedcars.bmw.co.uk/vehicle/api/list/?page=1&series=${serie}%20Series&size=23"
				refere="https://usedcars.bmw.co.uk/result/?page=1&series=${serie}+Series&size=23"
		fi 
		output=${dir}/${d}/LISTING/${serie}/page_0.html
		download_pages
		
		awk -f ${dir}/nb_annonce.awk ${dir}/${d}/LISTING/${serie}/page_0.html > ${dir}/${d}/LISTING/${serie}/nb_annonce.$$
		. ${dir}/${d}/LISTING/${serie}/nb_annonce.$$
		
		for (( page=2 ; page<=${max_page}; page++))
		do
			if [[ ${serie} == "BMWi" ]]; then 
					url="https://usedcars.bmw.co.uk/vehicle/api/list/?page=${page}&series=BMWi&size=23"
					refere="https://usedcars.bmw.co.uk/result/?page=${page}&series=BMWi&size=23"
			else 
					url="https://usedcars.bmw.co.uk/vehicle/api/list/?page=${page}&series=${serie}%20Series&size=23"
					refere="https://usedcars.bmw.co.uk/result/?page=${page}&series=${serie}+Series&size=23"
			fi 			
			output=${dir}/${d}/LISTING/${serie}/page_${page}.html			
			echo -e "${output}\t${url}\t${refere}" >> "${dir}/${d}/LISTING/${serie}/$$.wget_file"		
		done
		
		directory=${dir}/${d}/LISTING/${serie}/
		mkdir -p ${directory}/LOG
		
        list_file=${dir}/${d}/LISTING/${serie}/$$.wget_file
		download_list_multy_process		
		wait
		
		echo -e "parsing list" >> ${dir}/${d}/status		
		find ${directory}/ -type f -name '*.html' -exec  python3 ${dir}/parsing_json.py {} \; > ${directory}/${serie}.$$
		
		# Log Par SERIE
		cat  ${directory}/${serie}.$$  | sort -u -k1,1 > ${directory}/${serie}.tab
		nb_observe=`wc -l ${directory}/${serie}.tab | awk '{print $1}'`
		cat  ${directory}/${serie}.tab  >> ${dir}/${d}/extract.$$
		echo -e "${serie}\t${nb_annonce}\t${nb_observe}\tSERIE"
	done
	
	cat ${dir}/${d}/extract.$$ | sort -u -k1,1 >  ${dir}/${d}/extract.tab
	wait
	
    awk -vtable=${table} -f ${dir}/liste_tab.awk -f ${dir}/put_tab_into_db.awk  ${dir}/${d}/extract.tab > ${dir}/${d}/VO_ANNONCE_insert.sql
fi	

echo -e "FIN DU TELECHARGEMENT!"
ExitProcess 0

