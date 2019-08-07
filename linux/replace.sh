#!/bin/bash
extension='.'`date +%F-%s`'.bak'

help(){
	echo "Usage: $0 [option]... targetfile..."
	echo "Option:"
	echo " -b backupfile	Recursive backup the specified files(backupfile)"
	echo " -u"
}

backup(){
	echo "param: $1"
	local command="find ./ -name \"$1\" -type f -exec mv {} {}$extension \;"
	echo "$command"
        eval $command		
}

update(){
	echo "Update file $1 by $2"
	local command="find ./ -name \"$1\" -type f -exec dirname {} \;"
	for dir in `eval $command`
	do
		local copycommand="cp $2 ${dir}"
		echo "copy command: ${copycommand}"
		eval $copycommand
	done
}

rollback(){
	echo "Roll back backup: $1"

}

while getopts ":b:u:" opt
do
	case $opt in
		b)
		backup_str="$OPTARG"
		echo "b: $OPTARG"
		echo "back_str: ${backup_str}"
		;;
		u)
		update_str="$OPTARG"
		echo "Update file: $update_str"
		;;
		?)
		echo "Unknown args $opt"
		exit 1;;
	esac
done

if [ -n "${backup_str}" ] 
then
	echo "back_str: $backup_str"
	backup "${backup_str}"
fi

if [ -n "${update_str}" ]
then
	echo "Using update file: ${update_str}"
	update "${backup_str}${extension}" "${update_str}"
fi
