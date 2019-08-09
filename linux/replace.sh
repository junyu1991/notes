#!/bin/bash
#author: yujun

extension='.'`date +%F-%s`'.bak'
roll_back='.rollback'

help(){
	echo "Usage: $0 -b \"targetfile\" -p scanpath [option]..."
	echo "Option:"
	echo " -b backupfile,the file want to backup or upgrade,this param value must use ' or \" to surround"
	echo " -p scanpath,the path to scan"
	echo " -u updatefile, the file used to replace the backup file"
	echo " -r rollbackfile, roll back the backup operation"
	echo " -h help."
	exit 1
}

backup(){
	echo "Scan path : $2 to find file: $1"
	local command="find $2 -name \"$1\" -type f "
	echo "$command"
        for file in `eval $command`
	do
		mv ${file} ${file}${extension}
		echo "mv ${file}${extension} ${file}" >> ${roll_back}"/""`date +%s`""$1"
	done
}

update(){
	echo "Update file $1 by $2 under path $3"
	local command="find $3 -name \"$1\" -type f -exec dirname {} \;"
	for dir in `eval $command`
	do
		local copycommand="cp $2 ${dir}"
		echo "copy command: ${copycommand}"
		eval $copycommand
	done
}

#rollback目前还没有比较好的思路
rollback(){
	echo "Roll back backup: $1"

}

while getopts ":b:u:p:r:h" opt
do
	case $opt in
		b)
		backup_str="$OPTARG"
		echo "back_str: ${backup_str}"
		;;
		u)
		update_str="$OPTARG"
		echo "Update file: $update_str"
		;;
		p)
		scan_path="$OPTARG"
		echo "Scan path: $scan_path"
		;;
		r)
		roll_back_file="$OPTARG"
		echo "Roll back with file: $roll_back_file"
		;;
		h)
		help
		;;
		?)
		echo "Unknown args $opt"
		exit 1;;
	esac
done

mkdir $roll_back > /dev/null 2>&1

if [ -n "${backup_str}" -a -n "${scan_path}" ] 
then
	echo "back_str: $backup_str"
	backup "${backup_str}" $scan_path
else
	help
fi

if [ -n "${update_str}" -a -n "${backup_str}" -a -n "${scan_path}" ]
then
	echo "Using update file: ${update_str}"
	update "${backup_str}${extension}" "${update_str}" "$scan_path"
fi

if [ -n "${roll_back_file}" ]
then
	rollback "${roll_back_file}"
fi
