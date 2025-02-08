#!/bin/bash

cat $1 > work_file.txt
trap "rm work_file.txt" EXIT

#Pid of program
pids=()

#Dict with start_time for program with identical id
declare -A for_ids

#List of programs programs.txt
while read -r line || [[ -n "$line" ]]; 
do	
	echo " "
	#Name of program and id
	IFS='*' read -a idents <<< "$line"
	IFS=',' read -a prgrm <<< "$line" 
	name=(${prgrm[0]})
	id=(${idents[1]})
	
	#time_start for program with identical id
	current_time=$(date -d "$RTIME 60 minutes" +"%H:%M")
	now=$(date +"%s")
	next_start_time=$(($now + 3600))

	#time check for programs (60 minutes starts differences + 1) with the same id already launched
	if [[ -v for_ids["$id"] ]];
	then
		#allowed launch time with the current time
		if [[ $now -gt ${for_ids["$id"]} ]];
		then
			#"echo"-command simulated program_N launch
			echo "started $name after last program with same 'id'"
			echo  "$name" &
			pids+=( "$!" )		
			for_ids["$id"]=$next_start_time
		else
			#adding the program to the end of launching queue
			#
			#echo "no started $name with id $id at now"
			echo "$line" >> work_file.txt
		fi		
	
	else
		#started program_N if allowed
		echo "started $name with $id"
		echo "$name"
		
		#imitate work of program
		rand_start=$(( RANDOM % 2161 - 1080 ))
		rand_work_offset=$(( RANDOM % 10801 - 5400 ))
		work_time=$(( 18000 + $rand_start ))
		rand_work_time=$(( $rand_work_offset + $work_time))
		#echo "$rand_work_time" 		 
		sleep $rand_work_time &
		pids+=( "$!" )
		for_ids["$id"]=$next_start_time
	fi

	#1minute difference for start all program	
	sleep 60
	#check for four program
	if [ ${#pids[*]} -eq 4 ];
	then		
		for i in ${pids[@]}; do
			if ! ps -p "$i" &> /dev/null; then
				pids=("${pids[@]/$i/}")
			fi
		done
		sleep 1 
	fi	
done < work_file.txt
		


