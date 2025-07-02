#!/bin/bash

function log {  # log <LEVEL> [CATEGORY] <TEXT>
    FLOG_TIME=`date +"%F $(nmeter -d0 '%3t' | head -n1)"`
    FLOG_LEVEL="$1"
    if [ -z "$3" ]; then
        FLOG_CATEGORY=init
        FLOG_TEXT="$2"
    else
        FLOG_CATEGORY=$2
        FLOG_TEXT="$3"
    fi

    LOG_LEVEL_INDEX=2
    case $LOG_LEVEL in
        TRACE) LOG_LEVEL_INDEX=0 ;;
        DEBUG) LOG_LEVEL_INDEX=1 ;;
        INFO*) LOG_LEVEL_INDEX=2 ;;
        WARN*) LOG_LEVEL_INDEX=3 ;;
        ERROR) LOG_LEVEL_INDEX=4 ;;
        FATAL) LOG_LEVEL_INDEX=5 ;;
    esac

    case $FLOG_LEVEL in
        TRACE) [ 0 -ge "$LOG_LEVEL_INDEX" ] && printf "\e[34m$FLOG_TIME TRACE \e[34m$FLOG_CATEGORY: $FLOG_TEXT\e[0m\n" ;;
        DEBUG) [ 1 -ge "$LOG_LEVEL_INDEX" ] && printf "\e[34m$FLOG_TIME DEBUG \e[94m$FLOG_CATEGORY: $FLOG_TEXT\e[0m\n" ;;
        INFO)  [ 2 -ge "$LOG_LEVEL_INDEX" ] && printf "\e[36m$FLOG_TIME INFO  \e[96m$FLOG_CATEGORY: $FLOG_TEXT\e[0m\n" ;;
        WARN)  [ 3 -ge "$LOG_LEVEL_INDEX" ] && printf "\e[33m$FLOG_TIME WARN  \e[93m$FLOG_CATEGORY: $FLOG_TEXT\e[0m\n" >&2 ;;
        ERROR) [ 4 -ge "$LOG_LEVEL_INDEX" ] && printf "\e[31m$FLOG_TIME ERROR \e[91m$FLOG_CATEGORY: $FLOG_TEXT\e[0m\n" >&2 ;;
        FATAL) printf "\e[31m$FLOG_TIME FATAL \e[1;91m$LOG_CATEGORY: $LOG_TEXT\e[0m\n" >&2 ;;
        *)     printf "$FLOG_TIME  ???  $FLOG_CATEGORY: $FLOG_TEXT\n" ;;
    esac
}

exec 28433> /var/lock/entrypoint.lock
flock -n 28433 || { log ERROR "Script is already running" ; exit 113; }


while(true); do
    docker ps --format "{{.ID}} {{.Names}}" | sort -k2 | while IFS= read -r LINE; do
        PS_ID=$(echo $LINE | cut -d' ' -sf 1)
        PS_NAMES=$(echo $LINE | cut -d' ' -sf 2-)
        if [ $(docker ps -f "id=$PS_ID" -f "health=none" --format {{.ID}} | wc -l) -gt 0 ]; then
            log DEBUG $PS_ID "[none]      $PS_NAMES"
        elif [ $(docker ps -f "id=$PS_ID" -f "health=healthy" --format {{.ID}} | wc -l) -gt 0 ]; then
            log INFO  $PS_ID "[healthy]   $PS_NAMES"
        elif [ $(docker ps -f "id=$PS_ID" -f "health=starting" --format {{.ID}} | wc -l) -gt 0 ]; then
            log INFO  $PS_ID "[starting]  $PS_NAMES"
        elif [ $(docker ps -f "id=$PS_ID" -f "health=unhealthy" --format {{.ID}} | wc -l) -gt 0 ]; then
            log WARN  $PS_ID "[unhealthy] $PS_NAMES"
            log INFO $PS_ID  "Restarting"
            docker restart $PS_ID &>/dev/null
            if [ $? -ne 0 ]; then
                log ERROR $PS_ID "Restart failed"
            else
                log INFO  $PS_ID "Restarted"
            fi
            sleep 10
        else
            log INFO  $PS_ID "[unknown]   $PS_NAMES"
        fi
    done

    sleep ${INTERVAL:-60}
done
