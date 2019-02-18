#!/bin/bash

#
# Variables.
#
format=human

usage() {
    echo -e "$0: [-c]

    -c: output CSV format
"
}

#
# Script input sanitize.
#
options=$(getopt -o "c" -- $@)
if [ $? -ne 0 ]; then
    usage
    exit 1
fi

eval set -- "$options"
unset options

while true; do
    case "$1" in
        -c)
            format=csv
            shift
            ;;

        --)
            shift
            break
            ;;

        *)
            echo "Invalid option: $1"
            exit 1
    esac
done


#
# Start up.
#
output=$(smem -P "^(bgpd|staticd|zebra)" -t \
             | tail -n 1 \
             | sed -r 's/( )+/ /g' \
             | sed -r 's/^( )+//g')
instance_count=$(echo "$output" | cut -d ' ' -f 1)
pss_usage=$(echo "$output" | cut -d ' ' -f 5)

if [ $format == "human" ]; then
    echo -e "Instances\tPSS usage"
    echo -e "$instance_count\t\t$pss_usage"
else
    echo "$instance_count,$pss_usage"
fi

exit 0
