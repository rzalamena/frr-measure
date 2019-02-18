#!/bin/bash

usage() {
    echo -e "$0: -a amount [-e]

    -a amount: the amount of instances to run.
    -e: use exabgp to insert routes.
"
}

#
# Variables.
#
use_exabgp=0
exabgp_user=frr

#
# Script input sanitize.
#
options=$(getopt -o "a:e" -- $@)
if [ $? -ne 0 ]; then
    usage
    exit 1
fi

eval set -- "$options"
unset options

while true; do
    case "$1" in
        -a)
            amount=$2
            shift 2
            ;;

        -e)
            use_exabgp=1
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

if [ -z $amount ]; then
    echo "Please specify an amount"
    exit 1
fi

if [ $amount -lt 1 ]; then
    echo "Must be at least 1"
    exit 1
fi

if [ $amount -gt 254 ]; then
    echo "Must be less than 255"
    exit 1
fi


#
# Clean ups.
#

# Kill all old running processes.
pkill -9 zebra
pkill -9 bgpd
pkill -9 staticd
pkill -9 exabgp
pkill -9 python

# Remove temporary files.
rm -rf /var/run/frr/*

# Remove all loopback old addresses.
for instance in $(seq 1 254); do
    instance_addr=172.17.254.$instance

    ip addr del dev lo $instance_addr/32 >/dev/null 2>&1
done


#
# Start up.
#
for instance in $(seq 1 $amount); do
    instance_dir=/var/run/frr/r$instance
    instance_config_dir=/etc/frr/r$instance
    instance_addr=172.17.254.$instance
    instance_asn=100

    # Prepare environment.
    ip addr add dev lo $instance_addr/32

    mkdir -p $instance_dir
    mkdir -p $instance_config_dir
    chown -R frr:frr $instance_dir

    # Configure BGP to accept peers.
    cat >> $instance_config_dir/bgpd.conf <<EOF
router bgp $instance_asn
 neighbor 127.0.0.1 remote-as $instance_asn
!
EOF

    # Start daemons.
    zebra \
        -d -N r$instance -z $instance_dir/zserv.sock \
        --log file:$instance_dir/zebra.log --log-level debug
    staticd \
        -d -N r$instance -z $instance_dir/zserv.sock \
        --log file:$instance_dir/staticd.log --log-level debug
    bgpd \
        -d -N r$instance -z $instance_dir/zserv.sock \
        --log file:$instance_dir/bgpd.log --log-level debug \
        -n -l $instance_addr

    # Skip exabgp if configured to.
    if [ $use_exabgp -eq 0 ]; then
        continue
    fi

    cat >> $instance_dir/send-routes.py <<EOF
#!/usr/bin/env python

import sys
import time

routes = []
for net in range(1, 255):
    msg = 'announce route 10.254.{}.0/24 next-hop 172.17.0.1\n'.format(net)
    routes.append(msg)

amount = 1
for route in routes:
    sys.stdout.write(route)
    sys.stdout.flush()
    time.sleep(0.1)

try:
    while True:
        time.sleep(1)
except IOError:
    exit(1)

exit(0)
EOF

    chmod a+x $instance_dir/send-routes.py

    cat >> $instance_dir/exabgp.cfg <<EOF
process add-remove {
        run $instance_dir/send-routes.py;
        encoder json;
}

neighbor $instance_addr {
        router-id 172.17.0.1;
        local-address 127.0.0.1;
        local-as 100;
        peer-as 100;

        capability {
                graceful-restart;
        }

        api {
                processes [ add-remove ];
        }
}
EOF

    env \
        exabgp.daemon.daemonize=true \
        exabgp.daemon.user=$exabgp_user \
        exabgp.log.destination=$instance_dir/exabgp.log \
        exabgp.log.all=false \
        exabgp.log.configuration=true \
        exabgp.log.reactor=false \
        exabgp.log.daemon=false \
        exabgp.log.processes=true \
        exabgp.log.network=false \
        exabgp.log.packets=false \
        exabgp.log.rib=false \
        exabgp.log.message=false \
        exabgp.log.timers=false \
        exabgp.log.routes=true \
        exabgp.log.parser=false \
        exabgp.log.short=false \
        exabgp $instance_dir/exabgp.cfg
done

exit 0