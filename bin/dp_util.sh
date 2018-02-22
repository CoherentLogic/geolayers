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

    if [[ ${NEWSTATE} == $DP_COMPLETE ]]
    then
        logger "dp_dispatch [$$]:  DistributedProcess ID ${JOBID} COMPLETE"
    fi

    curl ${URL} &> /dev/null 

}
