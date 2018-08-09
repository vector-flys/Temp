#!/bin/bash

export TZ=US/Mountain
sd="$(date '+%Y%m%d-%H%M%S')"

# Functon to print error msg and exit
err_exit()
{
        if [[ "${1}" = /[0-9]*/ ]]; then
                ecode=${1}
                shift
        fi

        printf "${SCRIPTNAME} Error: ${*}\n" >&2
        exit ${ecode:-255}
}

tdesc=test_description.txt
echo "Enter test description - end w/CTRL-D"
cat > "${tdesc}"

# To benchmark, for example, matrix product for 60 seconds on 12 CPU threads, use:
mkdir -p "${sd}/"
[[ $? -ne 0 ]] && err_exit 10 "Failed to create output directory"
mv "${tdesc}" "${sd}/"
cd "${sd}"

dur=60
log="stress-ng_results.txt"

# Start monitor(s)
nohup vmstat 2 $(( (dur+5)/2 )) > vmstat.txt 2>&1 </dev/null &

(
stress-ng --cpu 12 --cpu-method matrixprod  --metrics-brief --perf -t ${dur} \
	> ${log} 2>&1
) &

printf "Duration = ${dur} seconds,\nLogfile = '${sd}/${log}'...\n\n"
while [[ $dur -gt 0 ]]; do
   echo -ne "$dur\033[0K\r"
   sleep 1
   : $((dur--))
done
