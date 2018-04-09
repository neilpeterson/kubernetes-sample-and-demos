
## Demo

Create two pods with similar labels and annotation.

```yaml
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
        dept: it
        owner: nepeters
      annotations:
        volume.beta.kubernetes.io/storage-class: managed-premium
    spec:
      containers:
      - name: kube-aci-demo
        image: microsoft/aci-helloworld
        ports:
        - containerPort: 80
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: kube-aci-demo-two
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: kube-aci-demo
        dept: finance
        owner: nepeters
      annotations:
        volume.beta.kubernetes.io/storage-class: managed-premium
    spec:
      containers:
      - name: kube-aci-demo-two
        image: microsoft/aci-helloworld
        ports:
        - containerPort: 80
```

Add a label to one of the pods.

```
kubectl label pod <pod> manager=jp
```

Get all pods with owner nepeters.

```
kubectl get pods -l owner=nepeters
```

Get all pods with any manager.

```
kubeclt get pods -l manager
```

Get all pods where dept is `finanace` using a set-based selector

```
kubectl get pods -l 'dept in (finance)'
```

Get all pods where dept is `finanace` or `it` using a set-based selector

```
kubectl get pods -l 'dept in (it,finance)'
```

Get all pods where dept is `finanace` or `it` and manager is `jp` using a set-based selector:

```
kubectl get pods -l 'dept in (it,finance),manager in (jp)'
```

Get all pods where dept is not `it` using a set-based selector:

```
kubectl get pods -l 'dept notin (it)'
```

Use equity-based label selector in API query:

```
curl http://localhost:8001/api/v1/namespaces/default/pods?labelSelector=dept%3Dfinance
```

Use set-based selector in API query:

```
curl http://localhost:8001/api/v1/namespaces/default/pods?labelSelector=dept+in+%28it%29
```