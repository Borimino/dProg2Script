#!/bin/bash

script=script.sh


# Resets the EDITOR, SHOULDNOTBERUN and DOWNLOAD_WHEN_FOUND fields if appropriate
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
		--runwithparam)
			perl -pi -e "s/RUN_WITH_PARAMETERS=\(.*\)/RUN_WITH_PARAMETERS=\(\)/g" $script
			;;
	esac
done

# For each parameter
while test $# -gt 0 ;
do
	# If the parameter is
	case "$1" in
		--help)
			# Echo the help-message and quit
			echo "Usage: $0 [--editor <EDITOR>] [--nottorun <FILENAME> [<FILENAME [<FILENAME> [...]]]]* [--downloadwhen <FILENAME> <URL>]* [--runwithparam <FILENAME> <ARGUMENT> [<ARGUMENT> [<ARGUMENT> [...]]]]*"
			exit
			;;
		--editor)
			# Pop the current parameter and set the editor the the next parameter and pop that
			shift

			perl -pi -e "s/EDITOR=\".*\"/EDITOR=\"$1\"/g" $script
			#script="${script/EDITOR_CHOICE/$1}"

			shift
			;;
		--nottorun)
			# Pop the current parameter
			shift

			nottorunArray=""

			# For each parameter, until the next "-"
			# add the parameter to the SHOULDNOTBERUN-field and pop it
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
			
			;;
		--downloadwhen)
			# Pop the current parameter
			shift

			# For each pair of parameters, until the next "-"
			# add the pair of parameters to the DOWNLOAD_WHEN_FOUND-field and pop them
			while test $# -gt 1 ;
			do
				if [[ ${1:0:1} != "-" ]];
				then
					perl -pi -e "s!DOWNLOAD_WHEN_FOUND=\(!DOWNLOAD_WHEN_FOUND=\($1 $2 !g" $script
					shift
					shift
				else
					break
				fi
			done
			;;
		--runwithparam)
			shift

			filename=$1
			shift

			param=""

			while test $# -ge 1 ;
			do
				if [[ ${1:0:1} != "-" ]]
				then
					param="$param $1"
					shift
				fi
			done

			perl -pi -e "s/RUN_WITH_PARAMETERS=\(/RUN_WITH_PARAMETERS=\($filename \"$param\"/g" $script
			;;
		*)
			shift

			;;
	esac
done

