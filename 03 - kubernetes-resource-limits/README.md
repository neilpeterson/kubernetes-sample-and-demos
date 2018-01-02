# Kubernetes Compute Resource Limits

## Overview

Four options that can be specified on each container in a pod.

- spec.containers[].resources.limits.cpu
- spec.containers[].resources.limits.memory
- spec.containers[].resources.requests.cpu
- spec.containers[].resources.requests.cpu

**Requests** are used at the time of scheduling. The scheduler will ensure that the selected node is capable of handeling the requests.

**Limits** are used durig run time. If a container exceeds it's memory limit, it may be restarted. If a contianer exceeds it's CPU limits, it will not be restarted.

## Sample

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
    spec:
      containers:
      - name: kube-aci-demo
        image: microsoft/aci-helloworld
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: 64i
            cpu: 250m
          limits:
            memory: 128i
            cpu: 500m
```

The sample can be run with the following command.

```
kubectl apply -f https://raw.githubusercontent.com/neilpeterson/kubernetes-sample-and-demos/master/03%20-%20kubernetes-resource-limits/memory-cpu.yaml

## Resources

Docs - https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/