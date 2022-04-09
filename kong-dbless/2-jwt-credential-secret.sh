kubectl create secret generic jwt-user-cred  \
  --from-literal=kongCredType=jwt \
  --from-file=rsa_public_key=key.pub  \
  --from-literal=key=jwt-user \ # jwt tokens ClientID which will be uniquely identified
  --from-literal=algorithm=RS256

# Added as consumer group which called acl credential
kubectl create secret generic api-user-acl --from-literal=kongCredType=acl --from-literal=group=api-user
