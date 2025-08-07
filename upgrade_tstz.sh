#!/bin/bash

if [ "$(whoami)" != "oracle" ]; then
    	echo "ERROR: you must run this script logged in as an oracle user"
	exit 1
fi

BASEDIR=$(dirname $0)

DATE=$(date +"%Y-%m-%d_%Hh%M")
LOGSDIR=${BASEDIR}/logs
LOGFILE=upgrade_tstz_${DATE}.log

echo "Clean old logs"
/usr/bin/find $LOGSDIR -mtime +240 -type f -name '*.log' -delete

if [ ! -d $LOGSDIR ]; then
    mkdir -p $LOGSDIR
    touch ${LOGSDIR}/$LOGFILE
    echo "$LOGSDIR doesn't exist => Creation of $LOGSDIR" | tee -a ${LOGSDIR}/$LOGFILE
fi

echo "Start upgrade_tstz.sh at $DATE" | tee -a ${LOGSDIR}/$LOGFILE

(${BASEDIR}/upgrade_tstz_core &>> ${LOGSDIR}/$LOGFILE &)
