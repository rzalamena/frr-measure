#!/bin/bash

#
# Variables.
#
format=human

usage() {
    echo -e "$0: -n instance_number -p prefix_number

    -n instance_number: which instance will be checked.
    -p prefix_number: number of prefixes.

Exits with status code 0 when `prefix_number` matches the current
amount otherwise 1.
"
    exit 255
}

#
# Script input sanitize.
#
options=$(getopt -o "n:p:" -- $@)
if [ $? -ne 0 ]; then
    usage
fi

eval set -- "$options"
unset options

while true; do
    case "$1" in
        -n)
            instance_number=$2
            shift 2
            ;;
        -p)
            prefix_number=$2
            shift 2
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

if [ -z $instance_number ] || [ $instance_number -le 0 ]; then
    echo "you must specify an instance number and it must be greater than 0"
    usage
fi

if [ -z $prefix_number ] || [ $prefix_number -le 0 ]; then
    echo "you must specify an prefix number and it must be greater than 0"
    usage
fi


#
# Start up.
#
actual_prefixes=$(vtysh -N r$instance_number \
                        -c "show bgp ipv4 unicast" 2>/dev/null \
                      | tail -n 1 \
                      | sed -r 's/( )+/ /g' \
                      | cut -d ' ' -f 2)

numre='^[0-9]+$'
if ! [[ $actual_prefixes =~ $numre ]]; then
    exit 1
fi

if [ $prefix_number -ne $actual_prefixes ]; then
    exit 1
fi

exit 0
