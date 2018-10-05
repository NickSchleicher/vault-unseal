#!/usr/bin/dumb-init /bin/sh

count=$((${VAULT_UNSEAL_RETRY_COUNT:-0}+1))
retry_seconds=${VAULT_UNSEAL_RETRY_SECOND:-5}

while [ "$count" -gt 0 ]; do
  http_code=$(curl --write-out %{http_code} --silent --output /dev/null $VAULT_ADDR/v1/sys/health)
  
  if [ $http_code == "503" ]; then
    echo "Vault server at $VAULT_ADDR is sealed, attempting unseal.";

    for key in $(echo $VAULT_KEYS | sed "s/,/ /g"); do
        [[ -n "$key" ]] & vault operator unseal ${key}
    done

    count=0;
  elif [ $http_code == "200" ]; then
    echo "Vault server at $VAULT_ADDR is unsealed, no action needed.";
    count=0;
  else
    count=$(($count - 1));
    echo "Vault server at $VAULT_ADDR is not in a state to be unsealed (reported HTTP code: $http_code). ($count retries remaining)";

    if [ "$count" -gt 0 ]; then
      sleep $retry_seconds
    fi
  fi
done

exec "$@"