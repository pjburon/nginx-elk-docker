#!/bin/sh

# Helper function to output error messages to STDERR, with red text
error() {
    (set +x; tput -Tscreen bold
    tput -Tscreen setaf 1
    echo $*
    tput -Tscreen sgr0) >&2
}

# Given a config file path, spit out all the ssl_certificate_key file paths
parse_keyfiles() {
    sed -n -e 's&^\s*ssl_certificate_key\s*\(.*\);&\1&p' "$1"
}

# Given a config file path, return 0 if all keyfiles exist (or there are no
# keyfiles), return 1 otherwise
keyfiles_exist() {
    for keyfile in $(parse_keyfiles $1); do
        if [ ! -f $keyfile ]; then
            echo "Couldn't find keyfile $keyfile for $1"
            return 1
        fi
    done
    return 0
}

# Helper function that checks if /etc/nginx/conf.d/kibana.conf has its keyfile yet, and disable it through renaming
auto_enable_configs() {
    conf_file="/etc/nginx/conf.d/kibana.conf"

    if keyfiles_exist $conf_file; then
        if [ ${conf_file##*.} = nokey ]; then
            echo "Found all the keyfiles for $conf_file, enabling..."
            mv $conf_file ${conf_file%.*}
        fi
    else
        if [ ${conf_file##*.} = conf ]; then
            echo "Keyfile missing for $conf_file, disabling..."
            mv $conf_file $conf_file.nokey
        fi
    fi
}

# Helper function to ask certbot for the given domain(s).  Must have defined the
# EMAIL environment variable, to register the proper support email address.
get_certificate() {
    echo "Getting certificate for domain $1 on behalf of user $2"

    certbot certonly --staging --agree-tos --keep -n --text --email $2 \
        https://acme-v01.api.letsencrypt.org/directory -d $1 \
        --standalone --standalone-supported-challenges http-01 --debug
}
