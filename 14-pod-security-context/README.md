# Pod / Container security context

A security context defines privileges and access controll for a pod or container.

- runAsUser - for any container in the pods, the first process runs with user ID 1000.
- fsGroup - group ID 2000 is associated with all containers in the pod.
- Capibiltiies - see [here](https://github.com/torvalds/linux/blob/master/include/uapi/linux/capability.h) for a list of capibilities.

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
      securityContext:
        runAsUser: 1000
        fsGroup: 2000
      containers:
      - name: kube-aci-demo
        image: ubuntu
        ports:
        - containerPort: 80
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            add: ["NET_ADMIN", "SYS_TIME"]
```