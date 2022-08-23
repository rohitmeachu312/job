#!/bin/bash

for DISPATCHER in VM00000598 VM00001227 VM00001232 VM00006190 VM00006191 VM00006192 VM00006193 VM00006194 VM00006195 VM00006196 VM00006197
do
  ps -ef | grep resam | grep -v grep && ps -ef | grep resamad | grep -v grep | awk '{print $2}' | sudo xargs kill -9

  ping -c 1 ${DISPATCHER}.solon.prd &>/dev/null
  if [[ $? -eq 0 ]] ; then
    # DISPATCHER is ONLINE
    echo 1 | sudo /usr/local/bin/resamad -dd${DISPATCHER}.solon.prd
    echo ""
    echo "--> Please wait... connecting to RES DISPATCHER ${DISPATCHER}"

    ACTIVE=0
    COUNTER=60

    while [[ ${COUNTER} -gt 0 ]] ; do
      if [[ -f /etc/res/resamad.xml ]] ; then
        ACTIVE=1
        COUNTER=0
      else
        sleep 1
        COUNTER=$(( COUNTER - 1 ))
      fi
    done

    if [[ ${ACTIVE} -eq 1 ]] ; then
      ps -ef | grep resam | grep -v grep && ps -ef | grep resamad | grep -v grep | awk '{print $2}' | sudo xargs kill -9
      sleep 1
      sudo /sbin/service resamad start
      [[ $? -eq 0 ]] && echo "RES agent installed and active."
      break
    fi
  fi
done
if [[ ${ACTIVE} -eq 0 ]] ; then
  echo "No RES Dispatcher responding..."
  exit 1
fi


