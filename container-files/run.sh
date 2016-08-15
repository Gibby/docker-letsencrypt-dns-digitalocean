#!/bin/bash

#Check if in DEBUG mode
DEBUG=${DEBUG:-no}
if [ "${DEBUG}" = "yes" ]; then
    set -x
    sed -i '2iset -x' /srv/letsencrypt/letsencrypt.sh
    sed -i '2iset -x' /srv/letsencrypt/letsencrypt.default.sh
fi

#Default to STAGING CA
STAGING=${STAGING:-yes}
if [ "${STAGING}" = "yes" ]; then
    echo 'CA="https://acme-staging.api.letsencrypt.org/directory"' > /srv/letsencrypt/config
fi


#Sleep time between runs
SLEEP=${SLEEP:-300}

#Make sure domains were specified
if [ -z "${DOMAINS}" ]; then
    echo "No domains specified"
    exit 1
else
    echo "${DOMAINS}" > /srv/letsencrypt/domains.txt
fi

# Set output directory
export ODIR=${ODIR:-"/srv/letsencrypt/certs/"}

# Put key in place for doctl
mkdir -p /root/.config/doctl
echo "access-token: ${TOKEN}" > /root/.config/doctl/config.yaml
chmod 0600 /root/.config/doctl/config.yaml 

cmd="/srv/letsencrypt/letsencrypt.sh --cron --hook /srv/letsencrypt/letsencrypt.default.sh --challenge dns-01 --out ${ODIR}"

while :
do
    $cmd
    echo "Sleeping for ${SLEEP}"
    sleep ${SLEEP}
done
