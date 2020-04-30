#!/bin/bash

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

function encrypt_str {
	#===============================================================================
	# This function will actually encrypt a given string with a given key.
	# The first parameter passed in (in $1) shall be the line to encrypt.
	# Second parameter passed in shall be the key to use to encrypt.
	# Third parameter shall be "" if no output file, otherwise it shall be the
	# filename.
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
	# This function will actually decrypt a given string with a given key.
	# The first parameter passed in (in $1) shall be the line to decrypt.
	# Second parameter passed in shall be the key used to encrypt.
	# Third parameter shall be "" if no output file, otherwise it shall be the
	# filename.
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
	# This function will act as a wrapper for encrypt_str.
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
	# This function will act as a wrapper for decrypt_str.
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

