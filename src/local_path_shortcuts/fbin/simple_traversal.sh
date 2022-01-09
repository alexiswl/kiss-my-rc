#!/usr/bin/env bash

# From https://gist.github.com/zachbrowne/8bc414c9f30192067831fafebd14255c

up ()
{
	local d=""
	limit=$1
	for ((i=1 ; i <= limit ; i++))
		do
			d=$d/..
		done
	d=$(echo $d | sed 's/^\///')
	if [ -z "$d" ]; then
		d=..
	fi
	cd "$d"
}