#!/usr/bin/env bash

#
# default values for options
#
filename=ssh.c
srcloc=./
targetloc=localhost:/tmp
attempts=10

#
# usage()
#
function usage {
    echo usage: "$(basename "\"${BASH_SOURCE[0]}\"")" [-a num_attempts] [-f filename_to_transfer] [-s source_location] [-t target_location]
}


while getopts "ha:f:s:t:" opt; do
    case $opt in
        a ) attempts=$OPTARG;;
        f ) filename=$OPTARG;;
        s) srcloc=$OPTARG;;
        t ) targetloc=$OPTARG;;
        h ) usage
            exit 0;;
        \?) usage
           exit 1;;
    esac
done

echo -e "attempts: ${attempts}\nfilename=${filename}\nsrcloc=${srcloc}\ntargetloc=${targetloc}\n"

## generate a random uuid for this run of the script
uuid=$(uuidgen)

for attempt in $(seq 1 "${attempts}"); do
    ts_epoch=$(epoch.py)
    targethost=$(echo "${targetloc}" | cut -d: -f 1)
    targetdir=$(echo "${targetloc}" | cut -d: -f 2)
    ./ssh "${targethost}" touch "${targetdir}"/"${uuid}"-"${ts_epoch}"-"${attempt}".txt
    ./scp -S ./ssh -vvv "${srcloc}"/"${filename}" "${targetloc}"/"${uuid}"-"${ts_epoch}"-"${filename}" &> /tmp/"${uuid}"-"${ts_epoch}"-debug.txt
done

# rm -f ~/ssh.c ./debug.txt && make && ./scp -S ./ssh ssh.c localhost:. > debug.txt 2>& 1 && diff ./ssh.c $HOME/ssh.c && shasum -a 256 ./ssh.c ~/ssh.c
