#!/bin/bash

if [ "$(whoami)" != "oracle" ]; then
    echo "ERREUR : vous devez exécuter ce script en étant connecté en tant qu'utilisateur oracle"
	exit 1
fi

BASEDIR=$(dirname $0)

DATE=$(date +"%Y-%m-%d_%Hh%M")
LOGSDIR=${BASEDIR}/logs
LOGFILE=patch_oracle_${DATE}.log

echo "Clean old logs"
/usr/bin/find $LOGSDIR -mtime +240 -type f -name '*.log' -delete

if [ ! -d $LOGSDIR ]; then
    mkdir -p $LOGSDIR
    touch ${LOGSDIR}/$LOGFILE
    echo "$LOGSDIR n'existe pas => Création de $LOGSDIR" | tee -a ${LOGSDIR}/$LOGFILE
fi

echo "Démarrage de patch_oracle.sh à $DATE" | tee -a ${LOGSDIR}/$LOGFILE

(${BASEDIR}/patch_oracle_core &>> ${LOGSDIR}/$LOGFILE &)
