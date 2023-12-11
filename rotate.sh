#!/bin/sh

max_backups=5
zip_backup=0


create_backup() {
	if ! [ -f "$file" ]; then
		printf "File '%s' not found.\n" "$file" >&2
		exit 1
	fi

	if ! [ -s "$file" ]; then
		exit 0
	fi

	if [ -f "$file.1" ] || [ -f "$file.1.gz" ]; then
		rotate_backups	
	fi

	if [ "$zip_backup" = 1 ]; then
		gzip -c "$file" > "$file.1.gz"
		touch -r "$file" "$file.1.gz"
	else
		cp "$file" "$file.1"
		touch -r "$file" "$file.1"
	fi
}


rotate_backups() {
	local current_backup=$max_backups

	rm "$file.$current_backup" "$file.$current_backup.gz" 2> /dev/null

	while [ "$current_backup" -gt 1 ]; do
		local last_backup=$(( current_backup - 1 ))

		if [ -f "$file.$last_backup" ]; then
			mv "$file.$last_backup" "$file.$current_backup"
		fi

		if [ -f "$file.$last_backup.gz" ]; then
			mv "$file.$last_backup.gz" "$file.$current_backup.gz"
		fi

		current_backup=$((  current_backup - 1 ))
	done
}


delete_backups() {
	if [ -f "$file" ]; then
		rm "$file".[0-9]* "$file".[0-9]*.gz 2> /dev/null
	fi
}


print_help() {
	help_message="Usage: rotate [OPTIONS] <FILENAME>
	
	-b N | Set the number of backups to keep. MIN=1 DEF=5 MAX=9
	-d   | Delete all backups for <FILENAME>.
	-h   | Displays this help message.
	-l   | Lists <FILENAME> and all backups for <FILENAME>.
	-z   | GZIPs the backup of <FILENAME>."
	printf "%s\n" "$help_message"
}


# Beginning of script that's always run.

option_set="def"


while getopts "b:dhlz" option; do
	case $option in
		b)
			if printf "%s" "$option_set" | grep -Eq "^[dhl]$"; then
				printf "Option -%s can't be used together with -b.\n" "$option_set" >&2
				exit 1
			fi
			
			option_set="b"

			if printf "%d" "$OPTARG" | grep -Eq "^[1-9]$"; then
				max_backups=$OPTARG
			else
				printf "Invalid number %d. N must be between 1-9.\n" "$OPTARG" >&2
				exit 1
			fi
			;;
		d)
			if [ $option_set != "def" ]; then
				printf "Option -%s can't be used together with -d.\n" "$option_set" >&2
				exit 1
			fi

			option_set="d"
			;;
		h)
			if [ $option_set != "def" ]; then
				printf "Option -%s can't be used together with -h.\n" "$option_set" >&2
				exit 1
			fi

			option_set="h"
			;;
		l)
			if [ $option_set != "def" ]; then
				printf "Option -%s can't be used together with -l.\n" "$option_set" >&2
				exit 1
			fi

			option_set="l"
			;;
		z)
			if printf "%s" "$option_set" | grep -Eq "^[dhl]$"; then
				printf "Option -%s can't be used together with -z.\n" "$option_set" >&2
				exit 1
			fi

			option_set="z"

			zip_backup=1
			;;
		\?)
			print_help
			exit 1
			;;
	esac
done


shift "$(( OPTIND - 1 ))"
file=$1


case $option_set in
	b)
		;;
	d)
		delete_backups
		exit 0
		;;
	h)
		print_help
		exit 0
		;;
	l)
		ls -l "$file" "$file".* 2> /dev/null
		exit 0
		;;
	z)
		;;
esac


create_backup 

exit 0
