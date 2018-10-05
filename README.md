# Vault-Unseal
`vault-unseal` is a simple tool that will automatically unseal your vault server.

  
### Instructions
Set the `VAULT_ADDR` environment variable to your vault's server address and set `VAULT_KEYS` to a comma separated list of your unseal keys. Run the container `nickschleicher/vault-unseal` The container will exit after the unsealing is finished.

  
### Example
Unseal a vault server that is named `vault` and is running on the same machine and docker network where this image is ran.
```
docker run -e VAULT_ADDR="http://vault:8200" -e VAULT_KEYS="key1,key2,key3" 
--network="docker_default" nickschleicher/vault-unseal
```  
  
Optional Environment Variables:
`VAULT_UNSEAL_RETRY_COUNT`: how many times to retry unsealing if vault server is not ready yet (default 0)
`VAULT_UNSEAL_RETRY_SECOND`: how long to wait in between retries (default 5)