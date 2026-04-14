#!/bin/bash

user_groups=("sistemas" "desarrollo")

addgroup informatica 

for user in "${user_groups[@]}"; do
	addgroup "$user"
       	for i in {1..5}; do
	adduser --disabled-password --gecos "" --ingroup "$user" "$user"0"$i"
	usermod -aG informatica "$user"0"$i"
	done
done

