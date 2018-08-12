#!/bin/sh

# Source in util.sh so we can have our nice tools
. $(cd $(dirname $0); pwd)/util.sh

# We require a domain name to register the ssl certificate for
if [ -z "$DOMAIN_NAME" ]; then
    error "DOMAIN_NAME environment variable undefined; certbot will do nothing"
    exit 1
fi

# We require an email to register the ssl certificate for
if [ -z "$CERTBOT_EMAIL" ]; then
    error "CERTBOT_EMAIL environment variable undefined; certbot will do nothing"
    exit 1
fi

exit_code=0
set -x

if ! get_certificate $DOMAIN_NAME $CERTBOT_EMAIL; then
    error "Cerbot failed for $DOMAIN_NAME. Check the logs for details."
    exit_code=1
fi

if [[ $exit_code -eq 0 ]]; then
    # After trying to get all our certificates, auto enable any configs that we  did indeed get certificates for
    auto_enable_configs

    # Finally, tell nginx to reload the configs
    kill -HUP $NGINX_PID
fi

set +x
exit $exit_code
