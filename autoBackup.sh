#!/bin/bash

dpkg -s dnsutils &> /dev/null

if [ $? -eq 0 ]; then
  echo ""
else
  apt install -y dnsutils
fi

if [ $? -eq 0 ]; then
  echo ""
else
  apt install -y rsync
fi

export GZIP=-9

local_backup=$false

ip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
allServers=(127.0.0.1 127.0.0.1)
server_1="127.0.0.1"
server_2="127.0.0.1"
server_3="127.0.0.1"
server_4="127.0.0.1"
server_5="127.0.0.1"
server_6="127.0.0.1"

backup_server="1.2.3.4"

date=$(date +'%m-%d-%Y')

daemon_dir="/var/lib/pterodactyl/volumes"


if [ -d "$daemon_dir" ]; then
  cd $daemon_dir
  if [ ! $local_backup ]; then
    for i in ${!allServers[@]}; do
      if [[ $ip == $backup_server ]]; then
        tar cvzf ./$date.tar.gz $daemon_dir
        rsync -a $daemon_dir/$date.tar.gz /backup/backup_server/
        rm ./$date.tar.gz
      else
        tar cvzf ./$date.tar.gz $daemon_dir
        rsync -avz -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --progress $daemon_dir/$date.tar.gz root@$backup_server:/backup/Server_$i/
        rm ./$date.tar.gz
      fi
    done
  else
    tar cvzf ./$date.tar.gz $daemon_dir
    rsync -a $daemon_dir/$date.tar.gz /backup/
    rm ./$date.tar.gz
  fi
else
  echo "Daemon Directory ($daemon_dir) doesn't exist!"
fi
