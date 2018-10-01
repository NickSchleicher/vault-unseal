#!/usr/bin/dumb-init /bin/sh

set -e

for key in $(echo $VAULT_KEYS | sed "s/,/ /g")
do
    [[ -n "$key" ]] & vault operator unseal ${key}
done

exec "$@"