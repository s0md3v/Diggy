#!/bin/bash

green='\033[1;32m'
end='\033[1;m'
info='\033[1;33m[!]\033[1;m'
que='\033[1;34m[?]\033[1;m'
bad='\033[1;31m[-]\033[1;m'
good='\033[1;32m[+]\033[1;m'
run='\033[1;97m[~]\033[1;m'

printf """$green     ___  _               
    / _ \(_)__ ____ ___ __
   / // / / _ \`/ _ \`/ // /
  /____/_/\_, /\_, /\_, / 
         /___//___//___/  

$end"""

if [ $1 ]
then
	:
else
	printf "Usage: ./apk.sh <path to apk file>\n"
	exit
fi

apk=$1
IFS='/' read -a temp <<< "$apk"
temp=${temp[-1]}
name=${temp::-4}
dir=$( pwd )

if type "apktool" > /dev/null; then
  :
else
	printf "$bad Diggy requires 'apktool' to be installed."
	exit
fi

check="$dir/$name"
if [ -e $check ]
then
	printf $"$info Looks like this apk has been decompiled already.\n"
    printf "$que"
    read -p " Decompile over the existing copy? [Y/n] " choice
    if [ choice == "y" ]
    then
    	:
    else
    	rm -r $check
    fi
else
    :
fi

check="$dir/$name.txt"
if [ -e $check ]
then
	printf $"$info Looks like links have been already extracted from this apk.\n"
	printf "$que"
    read -p " Rewrite the previous result? [Y/n] " choice
    if [ choice == "y" ]
    then
    	:
    else
    	rm $check
    fi
else
    :
fi

extract () {
	k=$(apktool d $apk -o $dir/$name)
}

grabby () {
	matches=$( grep -r "[\"]http.*//.*['\"]\|[\"]/.*['\"]" $dir/$name )
}

regxy () {
	for x in $matches
	do
		final=$(grep -o "[\"]http.*//.*['\"]\|[\"]/.*['\"]" <<< $x)
		final=${final//$"\""/}
		if [ "$final" == "/" ] || [ "$final" == "" ] || [ "$final" == "\"http\"" ] || [ "$final" == "\"https\"" ]
		then
			:
		else
			echo "$final" >> "$dir/$name.txt"
		fi
	done
}


printf $"$run Decompiling the apk\n"
extract
printf $"$run Extracting endpoints\n"
grabby
regxy
printf $"$info Endpoints saved in: $dir/$name.txt\n"
exit
