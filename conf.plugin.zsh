#!/bin/zsh

typeset -Ag conf_locations

local _conf_editor() {
	if ! [[ -w ${1} ]]; then
		sudoedit ${1}
	else
		$EDITOR ${1}
	fi
}

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
		cd $target
	elif [[ -f ${target} ]]; then
		_conf_editor $target
	elif [[ -n ${target} ]]; then
		echo "Conf target for $1 missing: $target"
	elif [[ -d $XDG_CONFIG_HOME/$1 ]]; then
		if [[ -f $XDG_CONFIG_HOME/$1 ]]; then
			_conf_editor $XDG_CONFIG_HOME/$1
		else
			targetfiles=($XDG_CONFIG_HOME/$1/*(N))
			if [[ $#targetfiles == 1 ]]; then
				_conf_editor $targetfiles[1]
			else
				cd $XDG_CONFIG_HOME/$1
			fi
		fi
	else
		targetfiles=($XDG_CONFIG_HOME/$1.*(.N))
		if [[ $#targetfiles == 1 ]]; then
			_conf_editor $targetfiles[1]
		elif [[ $#targetfiles -gt 1 ]]; then
			echo "Multiple possible matches:"
			printf " - %s\n" ${targetfiles[@]}
			echo "Please add an entry for it in conf's config (use \`conf conf\` to edit it)"
		else
			echo "Unknown conf target and no matching files in XDG_CONFIG_HOME: $1"
			echo "Please add an entry for it in conf's config (use \`conf conf\` to edit it)"
		fi
	fi

}

conf -r
