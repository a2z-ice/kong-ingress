kubectl create secret generic assad-jwt  \
  --from-literal=kongCredType=jwt \
  --from-file=rsa_public_key=key.pub  \
  --from-literal=key=jwt-user \
  --from-literal=algorithm=RS256

# Added as consumer group which called acl credential
kubectl create secret generic api-user-acl --from-literal=kongCredType=acl --from-literal=group=api-user
