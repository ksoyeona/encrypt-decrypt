#!/bin/bash
# Name:Soyeon Kim 
# Account ID: cs15wi20ase A13875135
# File: crypt.sh
# Assignment: Scripting Project
# Date:3/12/2020 

#===============================================================================
# DO NOT TOUCH BELOW THIS LINE
#===============================================================================

# This gets the character for a corresponding ASCII value
chr() {
	[ "$1" -lt 256 ] || return 1
	printf "\\$(printf '%03o' "$1")"
}

# This gets the ASCII value of a character
ord() {
	LC_CTYPE=C printf '%d' "'$1"
}


A_VAL=`ord A` # numerical value of the capital letter A
#===============================================================================
# DO NOT TOUCH ABOVE THIS LINE
#===============================================================================

function encrypt_str {
	#===============================================================================
	# Explanation:
	# This function will actually encrypt a given string with a given key.
	# The first parameter passed in (in $1) shall be the line to encrypt.
	# Second parameter passed in shall be the key to use to encrypt.
	# Third parameter shall be "" if no output file, otherwise it shall be the
	# filename.
	#
	# Here's the workflow:
	# 1. Create your index for looping through the key, and create your output
	#    string.
	# 2. For each line in the file, do the following:
	# 3. Grab the char at the current index
	# 4. If it's not a space, then do the following:
	# 5. Get the ASCII value of the current char.
	# 6. Get the index of the current char in the key
	# 7. Get the ASCII value of the char in the key.
	# 8. XXX USE THIS LINE TO GET THE ASCII VALUE OF THE REPLACEMENT CHAR XXX
	#       num=`echo "((<ascii value of current char> +
	#            <ascii_value of key char>) % 26) + $A_VAL" | bc`
	# 9. Get the corresponding char for that value using `ch $num`
	# 10. Append the char to the string.
	# 11. If the char was a space, just append it without doing any of the above
	#     steps
	# 12. At the end of the loop, if the output file is an empty string, print the
	#     line
	# 13. Otherwise, APPEND the string to the output file.
	#===============================================================================

	outputStr=""
	input=$1
	key=$2

	inputLast=`expr ${#input} - 1`
	space=0

	for i in $(seq 0 $inputLast)

	do
		if [ "${input:i:1}" != " " ]; then

			char=`ord "${input:i:1}"`

			keyLength=${#key}

			(( Index = i % $keyLength ))

			newIndex=`expr $Index - $space`

			charKey=`ord "${key:$newIndex:1}"`

			num=`echo "(($char + $charKey) % 26) + $A_VAL" | bc`

			encryptedChar=`chr "$num"`

			outputStr=$outputStr$encryptedChar

		elif [ "${input:i:1}" = " " ]; then

			outputStr="$outputStr "
			((space++))
		fi
	done

	if [ "$3" != "" ];then

		echo $outputStr >> $3

	elif [ "$3" = "" ];then

		echo $outputStr
	fi
}

function decrypt_str {
	#===============================================================================
	# Explanation:
	# This function will actually decrypt a given string with a given key.
	# The first parameter passed in (in $1) shall be the line to decrypt.
	# Second parameter passed in shall be the key used to encrypt.
	# Third parameter shall be "" if no output file, otherwise it shall be the
	# filename.
	#
	# Here's the workflow:
	# 1. Create your index for looping through the key, and create your output
	#    string.
	# 2. For each line in the file, do the following:
	# 3. Grab the char at the current index
	# 4. If it's not a space, then do the following:
	# 5. Get the ASCII value of the current char.
	# 6. Get the index of the current char in the key
	# 7. Get the ASCII value of the char in the key.
	# 8. XXX USE THIS LINE TO GET THE ASCII VALUE OF THE REPLACEMENT CHAR XXX
	#       num=`echo "((<ascii value of current char> -
	#            <ascii_value of key char> + 26) % 26) + $A_VAL" | bc`
	# 9. Get the corresponding char for that value using `ch $num`
	# 10. Append the char to the string.
	# 11. If the char was a space, just append it without doing any of the above
	#     steps
	# 12. At the end of the loop, if the output file is an empty string, print the
	#     line
	# 13. Otherwise, APPEND the string to the output file.
	#===============================================================================
	outputStr=""
	input=$1
	key=$2

	inputLast=`expr ${#input} - 1`
	space=0

	for i in $(seq 0 $inputLast)
	do
		if [ "${input:i:1}" != " " ]; then

			char=`ord "${input:i:1}"`

			keyLength=${#key}

			(( Index = i % $keyLength ))

			newIndex=`expr $Index - $space`

			charKey=`ord "${key:$newIndex:1}"`

			num=`echo "(($char - $charKey + 26) % 26) + $A_VAL" | bc`

			encryptedChar=`chr "$num"`

			outputStr=$outputStr$encryptedChar

		elif [ "${input:i:1}" = " " ]; then

			outputStr="$outputStr "
			((space++))
		fi
	done

	if [ "$3" = ""  ]; then

		echo $outputStr
	else
		touch $3

		echo $outputStr >> $3
	fi
}

function encrypt {
	#===============================================================================
	# Explanation:
	# This function will act as a wrapper for encrypt_str.
	#
	# Here's the workflow:
	# 1. Create your output file name string.
	# 2. Get the key from the user to use to encrypt.
	# 3. check if they wanna read from a file or from the command line.
	#    If they pick file, then get the name of the file they want to read.
	# 4. Ask if they want to output to a file or from the command line.
	#    If they pick file and gave an input file, the output file should
	#    be the name of the inputfile with ".enc" appended to it. Otherwise,
	#    prompt them for the filename they want to use and add ".enc" to it.
	#    If the output file exists already, be sure to delete it.
	# 5. If they picked a file, loop through the file line by line calling
	#    encrypt_str on each line of the file. Otherwise, prompt them for a string
	#    to encrypt and call encrypt_str on their string.
	#===============================================================================

	echo -n "Enter a key to use to encrypt: "

	read key

	echo -n "Read from (f)ile or (c)ommand line? "

	read input

	if [ "$input" = f ];then

		echo -n "Enter an input file: "
		read fileName

		echo -n "Output to (f)ile or (c)ommand line? "

		read output


	elif [ "$input" = c ];then

		echo -n "Output to (f)ile or (c)ommand line? "
		read output

		echo -n "Enter the string to encrypt: "
		read inputStr

	fi


	if [ "$input" = f ] && [ "$output" = f ];then

		rm -f $fileName.enc
		touch $fileName.enc

		while IFS= read -r line
		do
			encrypt_str "$line" $key $fileName.enc
		
		done < "$fileName"


	elif [ "$input" = f ] && [ "$output" = c ];then

		while IFS= read -r line
		do
			
			encrypt_str "$line" $key 

		done < "$fileName"

	elif [ "$input" = c ] && [ "$output" = c ];then

		echo `encrypt_str "$inputStr" $key ""`

	elif [ "$input" = c ] && [ "$output" = f ];then

		echo -n "Enter output filename: "
		read filename

		rm -f $filename.enc
		touch $filename.enc

		encrypt_str "$inputStr" $key $filename.enc

	fi
}



function decrypt {
	#===============================================================================
	# Explanation:
	# This function will act as a wrapper for decrypt_str.
	#
	# Here's the workflow:
	# 1. Create your output file name string.
	# 2. Get the key from the user used to encrypt
	# 3. check if they wanna read from a file or from the command line.
	#    If they pick file, then get the name of the file they want to read.
	# 4. Ask if they want to output to a file or from the command line.
	#    If they pick file and gave an input file, the output file should
	#    be the name of the inputfile without the ".enc" appended to it. Otherwise,
	#    prompt them for a filename and just use that one WITHOUT DOING ANYTHING TO IT.
	#    If the output file exists already, be sure to delete it.
	# 5. If they picked a file, loop through the file line by line calling
	#    decrypt_str on each line of the file. Otherwise, prompt them for a string
	#    to decrypt and call decrypt_str on their string.
	#===============================================================================
	echo -n "Enter a key used to encrypt: "

	read key

	echo -n "Read from (f)ile or (c)ommand line? "

	read input

	if [ "$input" = f ];then

		echo -n "Enter an input file: "
		read fileNameEnc

		echo -n "Output to (f)ile or (c)ommand line? "


		read output

	elif [ "$input" = c ];then

		echo -n "Output to (f)ile or (c)ommand line? "

		read output

	#	echo -n "Enter the string to decrypt: "
	#	read inputStr
	fi

	if [ "$input" = f ] && [ "$output" = f ];then


		fileName=${fileNameEnc%????}
		rm -f $fileName
		touch $fileName

		while IFS= read -r line
		do
			decrypt_str "$line" $key $fileName

		done < "$fileNameEnc"

	elif [ "$input" = f ] && [ "$output" = c ];then

		while IFS= read -r line
		do
			decrypt_str "$line" $key
		done < "$fileNameEnc"

	elif [ "$input" = c ] && [ "$output" = c ];then
		echo -n "Enter the string to decrypt: "
		read inputStr
		echo `decrypt_str "$inputStr" $key ""`


	elif [ "$input" = c ] && [ "$output" = f ];then

		echo -n "Enter output filename: "
		read filename

		rm -f $filename
		touch $filename
		echo -n "Enter the string to decrypt: "
		read inputStr
		decrypt_str "$inputStr" $key $filename
	fi

}

#===============================================================================
# DO NOT TOUCH BELOW THIS LINE
#===============================================================================
function main {

  # Read in which mode the user wants
  echo -n "(e)ncrypt or (d)ecrypt? "
  read repl
  echo

  if [ $repl == "e" ]; then
	  encrypt
  elif [ $repl == "d" ]; then
	  decrypt
  else
	  echo "Invalid option: $repl"
	  exit 1
  fi
}

main

#===============================================================================
# DO NOT TOUCH ABOVE THIS LINE
#===============================================================================
