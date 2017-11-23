#!/bin/bash

# Title       : SyncDnsCluster.sh
# Description : Bash script for cloud DNS cluster synchronization
# Author      : Alexandros Cardaris (cardaris@outlook.com)
# Date        : 2017-11-23
# Version     : 1.0.0
# Usage       : ./SyncDNSCluster.sh
# Notes       : We assume that you have already install and configure bind9
#               as well as ssh rsa authorised_keys in every DNS node


################ Global Variables ################

LOG="/var/log/SyncDnsCluster.log"
BIND9="/etc/bind/"
DEBUG=1

NODE_1=("10.1.0.5" "22" "root")
NODE_2=("10.1.0.7" "22" "root")
NODE_3=("10.1.0.10" "22" "root")
NODES=(
  NODE_1[@]
  NODE_2[@]
  NODE_3[@]
)
COUNTER=${#NODES[@]}


################ Functions ################

SyncDNSZones()
{
  NODE="${1:-0}"

  rsync -zrpog --delete-after -e "ssh -p ${!NODES[NODE]:1:1}" ${BIND9} ${!NODES[NODE]:2:1}@${!NODES[NODE]:0:1}:${BIND9}
  if [ $? -eq 0 ]; then
    if [ ${DEBUG} -eq 1 ]; then
      echo $(date)": SUCCESS | DNS ${!NODES[NODE]:0:1} is synchronized"
    else
      echo $(date)": SUCCESS | DNS ${!NODES[NODE]:0:1} was not synchronized" >> ${LOG}
    fi
  else
    if [ ${DEBUG} -eq 1 ]; then
      echo $(date)": FAILED  | DNS ${!NODES[NODE]:0:1} was not synchronized"
    else
      echo $(date)": FAILED  | DNS ${!NODES[NODE]:0:1} was not synchronized" >> ${LOG}
    fi
  fi
}

RestartDNS()
{
  ssh ${!NODES[NODE]:2:1}@${!NODES[NODE]:0:1} -p${!NODES[NODE]:1:1} "service bind9 restart"
  if [ ${?} -eq 0 ]; then
    if [ ${DEBUG} -eq 1 ]; then
      echo $(date)": SUCCESS | DNS ${!NODES[NODE]:0:1} bind9 service restarted"
    else
      echo $(date)": SUCCESS | DNS ${!NODES[NODE]:0:1} bind9 service restarted" >> ${LOG}
    fi
  else
    if [ ${DEBUG} -eq 1 ]; then
      echo $(date)": FAILED  | DNS ${!NODES[NODE]:0:1} bind9 service was not restarted"
    else
      echo $(date)": FAILED  | DNS ${!NODES[NODE]:0:1} bind9 service was not restarted" >> ${LOG}
    fi
  fi
}


################ Main ################

for (( i=0; i<${COUNTER}; i++ ));
do
  SyncDNSZones ${i}
  RestartDNS ${i}
done