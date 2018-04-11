# Kubernetes secrets

## Create Secret

Secrets can be created from a file, a manifest, or on the command line.

File:

```
kubectl create secret generic db-user --from-file=./username.txt
```

Manifest File:

Fist, base64 encode the secret:

```
$ echo -n "neillocal" | base64

bmVpbGxvY2Fs
```

Create the secret with a manifest file.

```
apiVersion: v1
kind: Secret
metadata:
  name: db-user
type: Opaque
data:
  username: bmVpbGxvY2Fs
```

Create a secret on the command line:

```
kubectl create secret generic db-user --from-literal=username="neillocal"
```

## Use secret

In data volume:

```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  volumes:
  - name: foo
    secret:
      secretName: db-user
```

Environment variable:

```
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: mycontainer
    image: redis
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: db-user
            key: username
  restartPolicy: Never
```

## Docker registry secrets

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
