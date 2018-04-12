# Service accounts

Provide an identity for a service running in a pod. This identity is used when the pod itself accesses the Kubernets API server or a Kubernetes secret.

Default account is `default`.

All namespaces have a default service account:

```
$ kubectl get serviceACcounts --all-namespaces

NAMESPACE      NAME       SECRETS   AGE
azure-system   default    1         12h
default        default    1         12h
kube-public    default    1         12h
kube-system    default    1         12h
kube-system    heapster   1         12h
kube-system    kube-dns   1         12h
```

Create a new service account:

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: this-admin
```

Create a pod that is configured with the service account:

```
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: kube-aci-demo
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: kube-aci-demo
    spec:
      containers:
      - name: kube-aci-demo
        image: ubuntu
        ports:
        - containerPort: 80
        serviceAccountName: this-admin
        automountServiceAccountToken: false
```