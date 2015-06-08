#! /bin/bash
#echo "|$1|$2|"
slash='---SLASH---'
char='---CHAR---'
prot='---PROTECTED---'
function swapchar {
#	>&2 echo "--swap-- 1: $1 2: $2 --swap--"
	temp1=$(echo $1 | sed 's/\\/'$slash'/g')
	temp1=$(echo $temp1 | sed 's/'$2'/'$char'/g')
	temp1=$(echo $temp1 | sed 's/'$slash$char'/'$2'/g')
	temp1=$(echo $temp1 | sed 's/'$char'/\\'$2'/g')
	temp1=$(echo $temp1 | sed 's/'$slash'/\\/g')
	echo $temp1;
}
function print3 {
	echo "1: $1"
	echo "2: $2"
	echo "3: $3"
}
swapper=$(swapchar "$2" '+')
swapper=$(swapchar "$swapper" '(')
repl=$(swapchar "$swapper" ')')
#>&2 echo "--repl-- $repl --repl--"

swapper=$(swapchar "$1" '+')
swapper=$(swapchar "$swapper" '(')
needle=$(swapchar "$swapper" ')')
#>&2 echo "--needle-- $needle --needle--"


#>&2 echo "--bef-- 1: $1 2: $2 --bef--"

if [ "$2" == "" ]; then
	while read a; do
		echo $a | sed -n 's/\('"$needle"'\)/\1/gp'
	done
else
	while read a; do
		echo $a | sed -n 's/'"$needle"'/'"$repl"'/gp'
	done
fi
