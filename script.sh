#!/bin/bash

# De klasser som du ved, ikke skal køres
SHOULDNOTBERUN=()

# Den editor, som du vil bruge
# Terminal-baserede editors giver problemer, da vi silencer deres output
EDITOR="gedit"

# De filer, som skal downloades, når en bestemt anden fil findes.
# F.eks.
#	DOWNLOAD_WHEN_FOUND=()
#	betyder:
#	Download "http://users-cs.au.dk/gudmund/dprog2_2014/eksempler/uge3/AccountTest.java" når du finder "Account.java"
#
# Flere sæt kan sættes efter hinanden, når blot der veksles mellem keys og values, og der startes med en key
DOWNLOAD_WHEN_FOUND=()

RUN_WITH_PARAMETERS=(CopyFile2.java " Account.java AccountTest.java Book2.txt")

#--------------------------------------Funktioner-----------------------------------------------

gudmund(){


	echo Running...
	pwd

	# Resetting the hasbeenrun-array
	hasbeenrun=$SHOULDNOTBERUN

	# Process every file in the current directory
	for f in *.java
	do

		echo "Processing $f"

		checkDownloads "$f"

		checkNameArrayAndRun "$f"


	done


	echo "${hasbeenrun[@]}"


	sleep 1

	# Opens every file in the current directory
	{ #Silences the folowing output START

	($EDITOR *.java)

	} &> /dev/null #Silence output STOP

}

#Puts all download-pairs in "HashMap"
init_download_list(){
	hinit downloads

	for (( i = 0 ; i < ${#DOWNLOAD_WHEN_FOUND[@]} ; i++ )) do
		hput downloads ${DOWNLOAD_WHEN_FOUND[i]} ${DOWNLOAD_WHEN_FOUND[i+1]}
		((i++))
	done

	for (( i = ${#DOWNLOAD_WHEN_FOUND[@]}-1 ; i >= 0 ; i-- )) do
		unset DOWNLOAD_WHEN_FOUND[i]
		((i--))
	done
}

# Puts all parameter-pairs in "HashMap"
init_parameter_list(){
	hinit parameters

	for (( i = 0 ; i < ${#RUN_WITH_PARAMETERS[@]} ; i++ )) do
		hput parameters ${RUN_WITH_PARAMETERS[i]} "${RUN_WITH_PARAMETERS[i+1]}"
		((i++))
	done

	for (( i = ${#RUN_WITH_PARAMETERS[@]}-1 ; i > 0 ; i-- )) do
		unset RUN_WITH_PARAMETERS[i]
		((i--))
	done

	#echo ${RUN_WITH_PARAMETERS[@]}
}

#HashMap-hack BEGIN
hinit() {
    rm -f /tmp/hashmap.$1
}

hput() {
    echo "$2 $3" >> /tmp/hashmap.$1
}

hget() {
    grep "^$2 " /tmp/hashmap.$1 | awk '{$1 = ""; print $0 };'
}
#HashMap-hack END

countDirectories () {
	
	subdircount=`find ./ -maxdepth 1 -type d | wc -l`

}

countJavaFiles(){

	subjavacount=`ls -1 *.java | wc -l` 2>/dev/null

}


# Checks whether the current file prompts the download of another file
checkDownloads(){

	if [[ ${#DOWNLOAD_WHEN_FOUND[@]} > 0 ]]
	then
		for filename in ${DOWNLOAD_WHEN_FOUND[@]}
		do
			if check $1 $filename ; then

				getFileName="$(hget downloads $1 | sed 's=.*/==')"

				echo "Getting $getFileName"

				wget -q $(hget downloads $1)

				echo "Processing $getFileName"

				checkNameArrayAndRun $getFileName
			fi
		done
	fi

}

# Checks whether the current file should be run with parameters
checkParameters(){
	
	if [[ ${#RUN_WITH_PARAMETERS[@]} > 0 ]]
	then
		for filename in ${RUN_WITH_PARAMETERS[@]}
		do
			if check $1 $filename ; then

				getParameters="$(hget parameters $1)"

				echo "$getParameters"
				return

			fi

		done
	fi

	return
}

#TODO: Could probably be omitted
checkNameArrayAndRun(){

	checkArrayAndRun $1

}


#Takes a name of a java file and runs the file if is is not in the hasbeenrun array 
checkArrayAndRun() {

	shouldrun="true"

	if [[ ${#hasbeenrun[@]} > 0 ]]
	then
		for java in ${hasbeenrun[@]}
		do

			if check $1 $java; then
			shouldrun="false"
			fi
			
		done
	fi


	if [[ "$shouldrun" == "true" ]]; then

		# Checks whether the file is in a package
		isinpackage=$(grep -n "package" $1 | head -n1)

		# Gets the current directory
		currentdir=${PWD##*/}

		# If it is in a package
		if [[ ${isinpackage:0:1} == "1" ]] ; then

			# Move out 1 directory
			cd ../

			#Compiles all the java files
			javac $currentdir/$1
			
			#Adds the found java to has been run
			hasbeenrun=(${hasbeenrun[@]}  $1)

			#Removes .java from filename so it can run
			l="$(echo $1 | sed 's/\.[^.]*$//')"

			#echo $(checkParameters $1)
			parameters="$(checkParameters $1)"
			#parameters=""

			# Gets the output from the java-command
			javatext="$((java -ea $currentdir.$l $parameters) 2>&1)"

			# If the output states, that there is no Main-method, 
			if [[ ${javatext:7:4} == "Main" ]] ; then
				# Do nothing
				sleep 0
			else
				# Else print the output
				echo $javatext
			fi

			# Go back into the directory
			cd $currentdir

		else

			#Compiles all the java files
			javac $1
			
			#Adds the found java to has been run
			hasbeenrun=(${hasbeenrun[@]}  $1)

			#Removes .java from filename so it can run
			l="$(echo $1 | sed 's/\.[^.]*$//')"

			#echo "$(checkParameters $1)"
			parameters="$(checkParameters $1)"
			#parameters=""

			#echo $parameters

			# Gets the output from the java-command
			javatext="$((java -ea $l $parameters) 2>&1)"


			# If the output states, that there is no Main-method, 
			if [[ ${javatext:7:4} == "Main" ]] ; then
				# Do nothing
				sleep 0
			else
				# Else print the output
				echo $javatext
			fi

		fi

	fi

}

removeSpecialCharacters() {

	for file in *.java 
	do

		#removes non UTF 8 caracters
		iconv -f utf-8 -t ascii -c $file > temp.java && mv temp.java $file

	done


}

# Checks whether 2 filenames are different
check() {

	if [ $1 != $2 ]; then

		return 1

	else 

		return 0

	fi


}

#TODO: Not used
space(){

	for num in {0..3} 
	do

		echo

	done

}

# Walks through the directories and runs everything in them
recursivewalkthrough(){

	countDirectories

	countJavaFiles

	# If there is more than 1 javafile, run it
	if [ $subjavacount -ge 1 ] ; then 

			run
	fi

	#if there are more than 1 subdirectory in current directory
	if [ $subdircount -ge 2 ]; then

		for d in */ ; do
			
			cd "$d"
			recursivewalkthrough
			cd ..

		done

	fi

}

run(){

	removeSpecialCharacters

	gudmund

}


#---------------------------------------Starten af udførslen -----------------------------------


#remove zip if exists
if [ -f *.zip ]; then

	unzip *.zip

    rm *.zip
	
fi 


#remove rar if exists
if [ -f *.rar ]; then

	unrar e *.rar

    rm *.rar
	
fi 


#remove mac files 
if [ -d __* ]; then
	rm -r __*
fi

init_download_list

init_parameter_list

recursivewalkthrough



# TODO:
# Handle multiple .zipfiles
