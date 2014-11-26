#!/bin/bash

#script=$(wget -q -O - http://pastebin.com/download.php?i=jADRZT69 | dos2unix -l)
#$(wget -q -O - "http://pastebin.com/raw.php?i=jADRZT69" | dos2unix > script.sh)
#chmod +x script.sh
script=script.sh
#script=${script/\r\n/\n}

#if [[ $# == 0 ]]; then
	#echo "Usage: $0 [--editor <EDITOR>] [--nottorun <FILENAME> [<FILENAME [<FILENAME> [...]]]]"
	#exit
#fi

for var in "$@"
do
	case "$var" in
		--editor)
			perl -pi -e "s/EDITOR=\".*\"/EDITOR=\"\"/g" $script
			;;
		--nottorun)
			perl -pi -e "s/SHOULDNOTBERUN=\(.*\)/SHOULDNOTBERUN=\(\)/g" $script
			;;
		--downloadwhen)
			perl -pi -e "s/DOWNLOAD_WHEN_FOUND=\(.*\)/DOWNLOAD_WHEN_FOUND=\(\)/g" $script
			;;
	esac
done

while test $# -gt 0 ;
do
	echo "$1"


	case "$1" in
		--help)
			echo "Usage: $0 [--editor <EDITOR>] [--nottorun <FILENAME> [<FILENAME [<FILENAME> [...]]]]* [--downloadwhen <FILENAME> <URL>]*"
			exit
			;;
		--editor)
			shift

			perl -pi -e "s/EDITOR=\".*\"/EDITOR=\"$1\"/g" $script
			#script="${script/EDITOR_CHOICE/$1}"

			shift
			;;
		--nottorun)
			shift

			nottorunArray=""

			while test $# -gt 0 ;
			do
				if [[ ${1:0:1} != "-" ]]; 
				then
					#nottorunArray="$nottorunArray $1"

					perl -pi -e "s/SHOULDNOTBERUN=\(/SHOULDNOTBERUN=\($1 /g" $script

					shift
				else
					break
				fi
			done

			#perl -pi -e "s/NOT_TO_RUN/$nottorunArray/g" $script
			#script="${script/NOT_TO_RUN/$nottorunArray}"
			
			;;
		--downloadwhen)
			shift

			while test $# -gt 1 ;
			do
				if [[ ${1:0:1} != "-" ]];
				then
					link=$(echo $2 | sed -e 's/\//\\\//g')
					perl -pi -e "s!DOWNLOAD_WHEN_FOUND=\(!DOWNLOAD_WHEN_FOUND=\($1 $2 !g" $script
					shift
					shift
				else
					break
				fi
			done
			;;
		*)
			shift

			;;
	esac
done

#echo $script
