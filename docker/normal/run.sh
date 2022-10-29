#!/bin/bash
export RUNNING_TYPE=docker
export C_FORCE_ROOT=true

redis-server --daemonize yes
COUNT=0
while true;
do
    pip install --upgrade flaskfarm
    python -m flaskfarm.main --repeat ${COUNT} --config "/data/config.yaml"
    RESULT=$?
    echo "PYTHON EXIT CODE : ${RESULT}.............."
    if [ "$RESULT" = "1" ]; then
        echo 'REPEAT....'
    else
        echo 'FINISH....'
        break
    fi
    COUNT=`expr $COUNT + 1`
done
