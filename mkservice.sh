#!/bin/bash
if [ "$EUID" -ne 0 ];then
	echo "Please run as root"
	exit
fi

if [[ "$#" -ne 3 ]]; then
	echo "Usage: ./mkservice <name> <executable path> <user>"
	exit
fi
name=$1
path=$(readlink -f $2)
user=$3
dir=${path%/*}

if [ ! -f "$path" ]; then
	echo "Executable does not exist on filesystem!"
	exit
fi

echo "
[Unit]
Description=$name
After=multi-user.target

[Service]
Type=idle
ExecStart=$path
WorkingDirectory=$dir
User=$user
Group=$user

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/${name}.service
systemctl daemon-reload
