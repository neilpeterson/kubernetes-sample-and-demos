# Image Pull Secret

## Create Secret

```
kubectl create secret docker-registry acr-auth --docker-server=https://myacrinstance.azurecr.io --docker-username=<sp-id> --docker-password=<sp-client-secret> --docker-email=user@contoso.com
```

## Use Secret in Manifest

```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: acr-auth-example
spec:
  template:
    metadata:
      labels:
        app: acr-auth-example
    spec:
      containers:
      - name: acr-auth-example
        image: myacrinstance.azurecr.io/acr-auth-example
      imagePullSecrets:
      - name: acr-auth
```
