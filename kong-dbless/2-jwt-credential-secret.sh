kubectl create secret generic assad-jwt  \
  --from-literal=kongCredType=jwt \
  --from-file=rsa_public_key=key.pub  \
  --from-literal=key=jwt-user \
  --from-literal=algorithm=RS256