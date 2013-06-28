#!/bin/bash
# *********************************************************
# file: array.inc.sh
# date: 08.10.2012
# author: (c) by Eric Yuan - <ericyiyuen@gmail.com>
# description: Little array library for bash.
# *********************************************************
#
#
# SYNOPSIS
#
# load this file in your main script:
#    test -f ./array.lib && . ./array.lib || exit 1
#
# to initialize the array
#    declare -a array=( one two three )
#    declare -a array2=( four five six )
#
#    echo "Display array (original) => ${array[@]}"
#
# add a second array to the end of first array - array_push
#    array=( $( array_push ${array[@]} ${array2[@]} ) )
#    echo "Display array (array_push) => ${array[@]}"
#
# delete last element from array - array_pop
#    array=( $( array_pop ${array[@]} ) )
#    echo "Display array (array_pop) => ${array[@]}"
#
# delete first element from array - array_shift
#    array=( $( array_shift ${array[@]} ) )
#    echo "Display array (array_shift) => ${array[@]}"
#
# merge one or more arrays together - array_merge
#    array3=( $( array_merge "${array[@]}" "${array2[@]}" ) )
#    echo "Display array (array_merge) => ${array3[@]}"
#
# check if the string 'nine' is in array 'array2' - in_array
#    if in_array "nine" "$array2" ; then
#        echo "The string 'nine' already exists."
#    fi
#
#
# *********************************************************
# add element to end of array => push
 
function array_push() {
 
local -a tmp=( $@ )
echo ${tmp[@]}
 
}
 
 
# *********************************************************
# delete a element from end of array => pop
 
function array_pop() {
 
local -a tmp=( $@ )
unset tmp[${#tmp[@]}-1]
echo ${tmp[@]}
 
}
 
 
# *********************************************************
# delete a element from begin of array => shift
 
function array_shift() {
 
local index=0
local -a tmp=( $@ )
 
# delete first element
unset tmp[0]
 
# move index of array one forward
for i in ${tmp[@]}; do
	tmp[$index]=$i
	let index=$index+1
done
 
# delete last element, otherwise available double
unset tmp[${#tmp[@]}-1]
 
echo ${tmp[@]}
 
}
 
 
# *********************************************************
# merge one or more arrays together => array_merge
 
function array_merge() {
 
declare -a a=( $( echo $* ) )
echo ${a[@]}
 
}
 
 
# *********************************************************
# checks if a value exists in an array => in_array
 
function in_array() {
 
local str=$1; shift
declare -a array=( $( echo $@ ) )
for (( i=0; i<${#array[*]}; i++ )); do
    [ "${array[$i]}" = "$str" ] && return 0
done
return 1
 
}

function array_dump() {

#: ${1?"Usage: function array_dump [\${array[@]}]"}
local arr=( "$@" )
#unset arr i
#local arr=( "1" "2" )
local i=0
# Loop array arr[]
for (( i=0;i<${#array[@]}; i++ )); do
    echo ${arr[$i]}
	#echo $i
done
echo 1


} 
 
# *********************************************************
# end of this library...
