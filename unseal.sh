#!/usr/bin/dumb-init /bin/sh

count=$((${VAULT_UNSEAL_RETRY_COUNT:-20}))
retry_seconds=${VAULT_UNSEAL_RETRY_SECOND:-3}

while [ "$count" -gt -1 ]; do
  http_code=$(curl --write-out %{http_code} --silent --output /dev/null $VAULT_ADDR/v1/sys/health)
  
  if [ $http_code == "503" ]; then
    echo "Vault server at $VAULT_ADDR is sealed, attempting unseal.";

    for key in $(echo $VAULT_KEYS | sed "s/,/ /g"); do
        [[ -n "$key" ]] & vault operator unseal ${key}
    done

    count=-1;
  elif [ $http_code == "200" ]; then
    echo "Vault server at $VAULT_ADDR is unsealed, no action needed.";
    count=-1;
  else
    count=$(($count - 1));
    echo "Vault server at $VAULT_ADDR is not in a state to be unsealed (reported HTTP code: $http_code). ($count retries remaining)";

    if [ "$count" -gt -1 ]; then
      sleep $retry_seconds
    fi
  fi
done

exec "$@"