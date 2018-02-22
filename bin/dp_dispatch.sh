#!/bin/bash

source /etc/default/dp_dispatch
source ${DP_BASEDIR}/dp_util.sh

DP_WAITNODE=0
DP_PROCESSING=1
DP_FAILED=2
DP_COMPLETE=3

WATCHED=$1
FILE=$2
EXT=${FILE: -4}
STATE=$DP_WAITNODE

cd ${WATCHED}

if [[ ${EXT} == ".job" ]]
then
    JOBID=$(basename $FILE .job)
    STATFILE="${JOBID}.stat"

    if [[ ! -f ${STATFILE} ]]
    then
        sleep 5
        touch ${STATFILE}

        SCRIPTNAME=$(cat ${FILE} | head -1)
        SCRIPTARGS=$(cat ${FILE} | head -2 | tail -1)
        DESCRIPTION=$(cat ${FILE} | tail -1)

        rm ${FILE}

        logger "dp_dispatch [$$]:  dispatching DistributedProcess ID ${JOBID} [${DESCRIPTION}]"
        updateServer ${JOBID} $DP_PROCESSING

        ${SCRIPTNAME} ${SCRIPTARGS}

        RET=$?

        if [[ $RET == 0 ]]
        then
            updateServer ${JOBID} $DP_COMPLETE
        else
            updateServer ${JOBID} $DP_FAILED
        fi

        rm ${STATFILE}

    fi
fi
