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

#--------------------------------------Funktioner-----------------------------------------------

gudmund(){


	echo Running...
	pwd

	hasbeenrun=$SHOULDNOTBERUN

	# Tilføjes til arrayet inden test 



	for f in *.java
	do

		echo "Processing $f"

		checkDownloads "$f"

		checkNameArrayAndRun "$f"


	done



	echo "${hasbeenrun[@]}"


	sleep 1

	#gedit *.java

	{ #Silences the folowing output START

	($EDITOR *.java)

	} &> /dev/null #Silence output STOP

	#sh /home/daniel/.apps-and-alike/idea-IU-135.1230/bin/idea.sh *.java


}

#Puts all download-pairs in "HashMap"
init_download_list(){
	hinit downloads

	for (( i = 0 ; i < ${#DOWNLOAD_WHEN_FOUND[@]} ; i++ )) do
		hput downloads ${DOWNLOAD_WHEN_FOUND[i]} ${DOWNLOAD_WHEN_FOUND[i+1]}
		((i++))
	done

	for (( i = 0 ; i < ${#DOWNLOAD_WHEN_FOUND[@]} ; i++ )) do
		((i++))
		DOWNLOAD_WHEN_FOUND=()
	done
}

#HashMap-hack BEGIN
hinit() {
    rm -f /tmp/hashmap.$1
}

hput() {
    echo "$2 $3" >> /tmp/hashmap.$1
}

hget() {
    grep "^$2 " /tmp/hashmap.$1 | awk '{ print $2 };'
}
#HashMap-hack END

countDirectories () {
	
	subdircount=`find ./ -maxdepth 1 -type d | wc -l`

}

countJavaFiles(){

	subjavacount=`ls -1 *.java | wc -l` 2>/dev/null

}


checkDownloads(){

	for filename in ${DOWNLOAD_WHEN_FOUND[@]}
	do
		if check $1 $filename; then

			getFileName="$(hget downloads $1 | sed 's=.*/==')"

			echo "Getting $getFileName"

			wget -q $(hget downloads $1)

			echo "Processing $getFileName"

			checkNameArrayAndRun $getFileName
		fi
	done

}

checkNameArrayAndRun(){
if [[ $1 == *Icon* ]]; then # AFLEVERINGSSPECIFIK. BØR NOK FJERNES

	#echo $1 indeholder Icon
	hasbeenrun=(${hasbeenrun[@]}  $1)


else

	#echo $1 indeholder ikke Icon
	checkArrayAndRun $1

fi


}


#Takes a name of a java file and runs the file if is is not in the hasbeenrun array 
checkArrayAndRun() {

shouldrun="true"

for java in "${hasbeenrun[@]}" then
do

	if check $1 $java; then
	#echo FALSE
	shouldrun="false"
	fi
	
done


if [[ "$shouldrun" == "true" ]]; then

	isinpackage=$(grep -n "package" $1 | head -n1)

	currentdir=${PWD##*/}

	if [[ ${isinpackage:0:1} == "1" ]] ; then
		cd ../

		#Compiles all the java files
		javac $currentdir/$1
		
		#Adds the found java to has been run
		hasbeenrun=(${hasbeenrun[@]}  $1)

		#sleep 1


		#Removes .java from filename so it can run
		l="$(echo $1 | sed 's/\.[^.]*$//')"

		javatext="$((java -ea $currentdir.$l) 2>&1)"

		if [[ ${javatext:7:4} == "Main" ]] ; then
			sleep 0
		else
			echo $javatext
		fi

		cd $currentdir

	else

		#Compiles all the java files
		javac $1
		
		#Adds the found java to has been run
		hasbeenrun=(${hasbeenrun[@]}  $1)

		#sleep 1


		#Removes .java from filename so it can run
		l="$(echo $1 | sed 's/\.[^.]*$//')"

		javatext="$((java -ea $l) 2>&1)"


		if [[ ${javatext:7:4} == "Main" ]] ; then
			sleep 0
		else
			echo $javatext
		fi

	fi

fi

}

removeSpecialCharacters() {

for file in *.java 
do

	#removes non UTF 8 caracters
	#echo $file
	iconv -f utf-8 -t ascii -c $file > temp.java && mv temp.java $file

done


}

#Takes a java file and the name of another java file. Runs the java file if they are NOT the same
check() {

if [ $1 != $2 ]; then

	return 1

else 

	return 0

fi


}

space(){

for num in {0..3} 
do

	echo

done

}

recursivewalkthrough(){

countDirectories

#echo "Heeeyy Jeg er i...:"
#pwd      

#echo $subdircount

countJavaFiles

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


#echo "Har jeg fundet den rigtige mappe"

#pwd

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

recursivewalkthrough



# TODO:
# Handle multiple .zipfiles
# Remove *ICON* test
