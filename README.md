# docker-letsencrypt-dns-digitalocean

This is a simple container to get certificates from [letsencrypt](https://letsencrypt.org/) by using dns-auth with [digitalocean](https://www.digitalocean.com/) 

## Changes/Additions
    None

## How to use
    Environment variables:
        - DOMAINS (What domains to get certs for, base domain needs to be first in the list)
            - foo.com test.foo.com test2.foo.com
        - TOKEN (API Token from [digitalocean](https://cloud.digitalocean.com/settings/api/tokens)
        - ODIR (Output directory for certificates, defaults to /srv/letsencrypt/certs/)
        - SLEEP (Time to sleep between runs, defaults to 300 seconds)
        - DEBUG (Enable debug output, defaults to no)
        - STAGING (To use the staging CA url, defaults to yes)
    Mounts:
        - Recommend mounting /srv/letsencrypt/certs/ or some other directory and specifying ODIR to make sure you save your certificates
        - You can also specify /srv/letsencrypt/do_deploy.sh script that will do some actions after creating/re-newing certificates

## Staging run example
    docker run \
    -e "DOMAINS=foo.com test.foo.com" \
    -e "TOKEN=xxxxx" \
    -v ${HOME}/letsencrypt-dns:/mnt \
    -e "ODIR=/mnt/certs" \
    gibby/letsencrypt-dns-digitalocean

## Live run example
    docker run -d \
    -e "DOMAINS=foo.com test.foo.com" \
    -e "TOKEN=xxxxx" \
    -v ${HOME}/letsencrypt-dns:/mnt \
    -e "ODIR=/mnt/certs" \
    -e "STAGING=no" \
    gibby/letsencrypt-dns-digitalocean

## Changelog

Please refer to: [CHANGELOG.md](CHANGELOG.md)

