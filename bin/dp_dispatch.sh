#!/bin/bash

source /etc/default/dp_dispatch

DP_WAITNODE=0
DP_PROCESSING=1
DP_FAILED=2
DP_COMPLETE=3

WATCHED=$1
FILE=$2
EXT=${FILE: -4}
STATE=$DP_WAITNODE

function updateServer {

    local DPID=$1
    local NEWSTATE=$2
    local URL="${DP_URL}?distributedProcessId=${DPID}&newState=${NEWSTATE}"

    OLDSTATE=$STATE
    STATE=$NEWSTATE

    logger "dp_dispatch [$$]:  DistributedProcess ID ${JOBID} state transition (${OLDSTATE}->${NEWSTATE})"

    if [[ ${NEWSTATE} == $DP_FAILED ]]
    then
        logger "dp_dispatch [$$]:  DistributedProcess ID ${JOBID} FAILED"
    fi

    wget ${URL} &> /dev/null

}



cd ${WATCHED}

if [[ ${EXT} == ".job" ]]
then
    JOBID=$(basename $FILE .job)
    STATFILE="${JOBID}.stat"

    if [[ ! -f ${STATFILE} ]]
    then
        touch ${STATFILE}

        SCRIPTNAME=$(cat ${FILE} | head -1)
        SCRIPTARGS=$(cat ${FILE} | head -2 | tail -1)
        DESCRIPTION=$(cat ${FILE} | tail -1)

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
