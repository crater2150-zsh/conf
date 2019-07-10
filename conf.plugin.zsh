#!/bin/zsh

typeset -Ax conf_locations

conf() {
	if [[ $1 == -r ]]; then
		local confconf=$ZDOTDIR/confs
		if [[ -e $confconf ]]; then
			conf_locations[conf]=$confconf
			conf_locations+=( $(<$confconf) )
		fi
		return
	fi

	if [[ -z $1 ]]; then
		echo "Available configs:"
		for k v in ${(kv)conf_locations}; do
			if [[ -e ${(e)v} ]]; then
				printf "%-20s %s\n" ${k}: ${(e)v}
			fi
		done
		return 1
	fi

	local target=${(e)conf_locations[${1}]}
	if [[ -d ${target} ]]; then
		cd ${target}
		if ! [[ -w ${target} ]]; then
			su
		fi
	elif [[ -f ${target} ]]; then
		if ! [[ -w ${target} ]]; then
			sudoedit ${target}
		else
			$EDITOR ${target}
		fi
	elif [[ -n ${target} ]]; then
		echo "Conf target for $1 missing: $target"
	else
		echo "Unknown conf target: $1"
	fi

}

conf -r
