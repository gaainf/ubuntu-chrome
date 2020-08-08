#!/bin/bash

#global constants
ALLOWED_ACTIVE_SESSIONS=1
ACTIVITY_TIMEOUT=120
SLEEP_TIMEOUT=10
PROCESS_REGEX="chromedriver"

print_tree() {
    local parent=$1 child
    for child in $(ps -x -o ppid=,pid= | awk "{if (\$1==$parent) {print \$2}}"); do
        print_tree $child
    done
    #ps -o pid,ppid,etime,ucomm -p $parent
    #kill $parent
    echo $parent
}

kill_all() {
    for pid in "$@"; do
        echo "try to kill $pid"
        kill -9 $pid
    done
}

to_seconds() {
    uname=$(uname)
    #get epoch time local epoch=$(date -u -d @0 +%F) or local epoch=$(date -u -r0 +%F)
    local epoch="1970-01-01"
    local time=$1
    local colons="${time//[^:]}"
    if (( "${#colons}" == "1" )); then
        time="00:$time"
    fi
    if [ $uname == "Darwin" ]; then
        date -u -j -f "%Y-%m-%d %H:%M:%S" "$epoch $time" +%s
    else
        date -u -d "$epoch $time" +%s
    fi
}


clear_dangling() {
    local etimes=()

    IFS='
'
    processes=( $(ps -x -o etime=,pid=,ucomm= | grep "$PROCESS_REGEX") )
    unset IFS
    if (( "${#processes[@]}" > "$ALLOWED_ACTIVE_SESSIONS" )); then
        for process in "${processes[@]}" ; do
            local arr=(${process// / })
            local etime="${arr[0]}"
            local pid="${arr[1]}"
            local ucomm="${arr[2]}"
            if [ -z "${pid##[0-9]*}" ]; then #is digit
                etime=$(echo $etime | sed -E "s/([0-9]+)-([0-9])/\2/")
                local etime_in_sec="$(to_seconds $etime)"
                #if [ $etime_in_sec -ge $ACTIVITY_TIMEOUT ] ; then
                    etimes+=([$etime_in_sec]=$pid)
                #fi
            fi
        done

        #sort them all
        local sorted_etimes=( $(printf '%s\n' "${!etimes[@]}" |sort -n) )
        #kill someone
        local index=1
        for k in "${sorted_etimes[@]}"; do
            if (( "$index" > "$ALLOWED_ACTIVE_SESSIONS" )); then
                if [ $k -ge $ACTIVITY_TIMEOUT ] ; then
                    echo "$index: let's kill"
                    echo "parent: etime=$k, pid=${etimes[$k]}"
                    child=( $(print_tree ${etimes[$k]}) )
                    echo "children: ${child[@]}"
                    kill_all ${child[@]}
                    echo "try to kill parent ${etimes[$k]}"
                    kill -9 ${etimes[$k]}
                else
                    echo "$index: too fresh to kill"
                    echo "parent: etime=$k, pid=${etimes[$k]}"
                    child=( $(print_tree ${etimes[$k]}) )
                    echo "children: ${child[@]}"
                fi
            else
                echo "$index: active"
                echo "parent: etime=$k, pid=${etimes[$k]}"
                child=( $(print_tree ${etimes[$k]}) )
                echo "children: ${child[@]}"
            fi
            index=$(( $index + 1 ))
        done
    else
        echo "Nothing to kill"
    fi
}

while :
do
    clear_dangling $1
    sleep $SLEEP_TIMEOUT
done
