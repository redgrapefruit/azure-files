#!/bin/bash
#
array_check () {
for i in ${currentlist[@]};do
  if [ "$1" = "$i" ];then
    return 1
  fi
  done
  return 0
}

#
HOSTGROUPFILE=/tmp/hostgroup
sudo qconf -shgrp @default > ${HOSTGROUPFILE}
currentlist=($(tail -n +2 ${HOSTGROUPFILE} | sed -e 's/^hostlist//' | awk '{print $1;}' | awk -F. '{print $1;}'))

#
ADDNEWHOST=0

#for i in {0..2}
for i in {0..253}
do
  EXECHOST="exec-${i}"
  # echo ${EXECHOST}
  ping -c 1 ${EXECHOST} &> /dev/null
  RET=$?
  if [ ${RET} -eq 0 ];
  then
    # echo "FOUND new host by ping [${EXECHOST}]"
    array_check ${EXECHOST}
    CHECK=$?
    if [ ${CHECK} -eq 0 ];
    then
      # echo "ADD host [${EXECHOST}]"
      currentlist=("${currentlist[@]}" "${EXECHOST}")
      ADDNEWHOST=1
    fi
  fi
done

#
if [ ${ADDNEWHOST} -eq 1 ];
then
  NEWHOSTLIST="hostlist"
  for i in ${currentlist[@]};do
    NEWHOSTLIST="${NEWHOSTLIST} ${i}"
  done
  echo "NEW HOST LIST"
  echo ${NEWHOSTLIST}
  sed -e "s/^hostlist.*$/${NEWHOSTLIST}/" /tmp/hostgroup > /tmp/newhostgroup
  sudo qconf -Mhgrp ${HOSTGROUPFILE}
fi
