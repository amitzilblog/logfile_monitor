#!/bin/bash

# variables
HASH_LINES=10
INTERNAL_FILE=/tmp/monitor_internal_file

function sameFile() {
   type="$1"
   hash="$2"

   if [ ! -f ${INTERNAL_FILE} ]; then
      echo "false"
   else
      new_hash=$(grep -e "^${type}_HASH:" $INTERNAL_FILE | sed -e "s/^${type}_HASH://g")
      if [ -z "${new_hash}" ]; then
         echo "false"
      else
         if [ "${new_hash}" = "${hash}" ]; then
            echo "true"
         else
            echo "false"
         fi
      fi
   fi
}

function getFileLine() {
   type="$1"
   filename="$2"

   hash=$(head -n ${HASH_LINES} ${filename} | md5sum)
   is_same_file=$(sameFile "${type}" "${hash}")
   if [ "${is_same_file}" = true ]; then
      line=$(grep -e "^${type}_LINE:" ${INTERNAL_FILE} | sed -e "s/^${type}_LINE://g")
      if [ -z "${line}" ]; then
         RC=0
      else
         RC=$line
      fi
   else
      RC=0
   fi
   new_line=$(wc -l ${filename} | cut -f 1 -d ' ')
   sed -i "/^${type}_LINE:/d" ${INTERNAL_FILE} 2>/dev/null
   sed -i "/^${type}_HASH:/d" ${INTERNAL_FILE} 2>/dev/null
   echo "${type}_HASH:${hash}" >> ${INTERNAL_FILE}
   echo "${type}_LINE:${new_line}" >> ${INTERNAL_FILE}
   echo $RC
}

my_log=/var/log/messages
line=$(getFileLine "SYSLOG" "${my_log}")
((line++))
new_lines=$(tail -n +${line} ${my_log})
echo "${new_lines}"
