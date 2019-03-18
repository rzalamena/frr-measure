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
output=$(smem -P "^(bgpd|staticd|zebra|ospfd|isisd)" -t \
             | tail -n 1 \
             | sed -r 's/( )+/ /g' \
             | sed -r 's/^( )+//g')
instance_count=$(echo "$output" | cut -d ' ' -f 1)
pss_usage=$(echo "$output" | cut -d ' ' -f 5)

bgp_output=$(smem -P "^bgpd" -t \
                 | tail -n 1 \
                 | sed -r 's/( )+/ /g' \
                 | sed -r 's/^( )+//g' \
                 | cut -d ' ' -f 5)
staticd_output=$(smem -P "^staticd" -t \
                     | tail -n 1 \
                     | sed -r 's/( )+/ /g' \
                     | sed -r 's/^( )+//g' \
                     | cut -d ' ' -f 5)
zebra_output=$(smem -P "^zebra" -t \
                   | tail -n 1 \
                   | sed -r 's/( )+/ /g' \
                   | sed -r 's/^( )+//g' \
                   | cut -d ' ' -f 5)
ospfd_output=$(smem -P "^ospfd" -t \
                   | tail -n 1 \
                   | sed -r 's/( )+/ /g' \
                   | sed -r 's/^( )+//g' \
                   | cut -d ' ' -f 5)
isisd_output=$(smem -P "^isisd" -t \
                   | tail -n 1 \
                   | sed -r 's/( )+/ /g' \
                   | sed -r 's/^( )+//g' \
                   | cut -d ' ' -f 5)

if [ $format == "human" ]; then
    echo -e "Instances\tPSS usage\tBGP\tstaticd\tzebra\tospfd\tisisd"
    echo -e "$instance_count\t\t$pss_usage\t\t$bgp_output\t$staticd_output\t$zebra_output\t$ospfd_output\t$isisd_output"
else
    echo "$instance_count,$pss_usage,$bgp_output,$staticd_output,$zebra_output,$ospfd_output,$isisd_output"
fi

exit 0
