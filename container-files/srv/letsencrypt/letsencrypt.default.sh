#!/usr/bin/env bash
#
# Example how to deploy a DNS challange using lexicon

set -e
set -u
set -o pipefail

function deploy_challenge {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

    echo "deploy_challenge called: ${DOMAIN}, ${TOKEN_FILENAME}, ${TOKEN_VALUE}"

    local DOMAIN
    local SUBDOMAIN
    if [[ -z "${1/*.*.*/}" ]]; then
        DOMAIN=${1#*.}
        SUBDOMAIN=${1%%.*}
    else
        DOMAIN=$1
        SUBDOMAIN=''
    fi

    doctl compute domain records create ${DOMAIN} --record-type TXT --record-name "_acme-challenge.${SUBDOMAIN}" --record-data "${TOKEN_VALUE}"

    sleep 30

    # This hook is called once for every domain that needs to be
    # validated, including any alternative names you may have listed.
    #
    # Parameters:
    # - DOMAIN
    #   The domain name (CN or subject alternative name) being
    #   validated.
    # - TOKEN_FILENAME
    #   The name of the file containing the token to be served for HTTP
    #   validation. Should be served by your web server as
    #   /.well-known/acme-challenge/${TOKEN_FILENAME}.
    # - TOKEN_VALUE
    #   The token value that needs to be served for validation. For DNS
    #   validation, this is what you want to put in the _acme-challenge
    #   TXT record. For HTTP validation it is the value that is expected
    #   be found in the $TOKEN_FILENAME file.
}

function clean_challenge {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

    echo "clean_challenge called: ${DOMAIN}, ${TOKEN_FILENAME}, ${TOKEN_VALUE}"

    local DOMAIN
    local SUBDOMAIN
    if [[ -z "${1/*.*.*/}" ]]; then
        DOMAIN=${1#*.}
        SUBDOMAIN=${1%%.*}
    else
        DOMAIN=$1
        SUBDOMAIN=''
    fi 

    record_id=`doctl compute domain records list ${DOMAIN} | grep "_acme-challenge.${SUBDOMAIN}" | sed -nr "/${TOKEN_VALUE}/p" | awk '{print $1}'`
    doctl compute domain records delete ${DOMAIN} ${record_id}

    # This hook is called after attempting to validate each domain,
    # whether or not validation was successful. Here you can delete
    # files or DNS records that are no longer needed.
    #
    # The parameters are the same as for deploy_challenge.
}

function deploy_cert {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"

    echo "deploy_cert called: ${DOMAIN}, ${KEYFILE}, ${CERTFILE}, ${FULLCHAINFILE}, ${CHAINFILE}"

    bash /srv/letsencrypt/do_deploy.sh $@

    # This hook is called once for each certificate that has been
    # produced. Here you might, for instance, copy your new certificates
    # to service-specific locations and reload the service.
    #
    # Parameters:
    # - DOMAIN
    #   The primary domain name, i.e. the certificate common
    #   name (CN).
    # - KEYFILE
    #   The path of the file containing the private key.
    # - CERTFILE
    #   The path of the file containing the signed certificate.
    # - FULLCHAINFILE
    #   The path of the file containing the full certificate chain.
    # - CHAINFILE
    #   The path of the file containing the intermediate certificate(s).
}

function unchanged_cert {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"

    echo "unchanged_cert called: ${DOMAIN}, ${KEYFILE}, ${CERTFILE}, ${FULLCHAINFILE}, ${CHAINFILE}"

    # This hook is called once for each certificate that is still
    # valid and therefore wasn't reissued.
    #
    # Parameters:
    # - DOMAIN
    #   The primary domain name, i.e. the certificate common
    #   name (CN).
    # - KEYFILE
    #   The path of the file containing the private key.
    # - CERTFILE
    #   The path of the file containing the signed certificate.
    # - FULLCHAINFILE
    #   The path of the file containing the full certificate chain.
    # - CHAINFILE
    #   The path of the file containing the intermediate certificate(s).
}

HANDLER=$1; shift; $HANDLER "$@"
