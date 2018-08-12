#!/bin/sh

# When we get killed, kill all our children
trap "exit" INT TERM
trap "kill 0" EXIT

# Source in util.sh so we can have our nice tools
. $(cd $(dirname $0); pwd)/util.sh

# Create Kibana username and password into htpasswd file
KIBANA_USERNAME=${KIBANA_USERNAME:-admin}
KIBANA_PASSWORD=${KIBANA_PASSWORD:-admin}
HTPASSWD_FILE="/etc/nginx/conf.d/kibana.htpasswd"
if [ -f $HTPASSWD_FILE ] ; then
    rm $HTPASSWD_FILE
fi
htpasswd -c -b ${HTPASSWD_FILE} ${KIBANA_USERNAME} ${KIBANA_PASSWORD}

# Immediately run auto_enable_configs so that nginx is in a runnable state
auto_enable_configs

# Start up nginx, save PID so we can reload config inside of run_certbot.sh
nginx -g "daemon off;" #&
export NGINX_PID=$!

# Next, run certbot to request all the ssl certs we can find
/scripts/run_certbot.sh

# Instead of trying to run `cron` or something like that, just leep and run `certbot`.
while [ true ]; do
    # Sleep for 1 week
    sleep 604800 &
    SLEEP_PID=$!

    # re-run certbot
    /scripts/run_certbot.sh

    # Wait on sleep so that when we get ctrl-c'ed it kills everything due to our trap
    wait "$SLEEP_PID"
done
