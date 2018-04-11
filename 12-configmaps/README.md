# ConfigMaps

Create a simple config map

```
kubectl create configmap test-configmap --from-literal=department=it --from-literal=owner=nepeters
```

Now use the config map to populate pod environment variables:

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
        image: microsoft/aks-helloworld
        ports:
        - containerPort: 80
        env:
          - name: TEST_VAR
            valueFrom:
                configMapKeyRef:
                    name: test-configmap
                    key: department
```

Config map data can be used to populate container run commands.

```
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: gcr.io/google_containers/busybox
      command: [ "/bin/sh", "-c", "echo $(TEST_VAR)]
        env:
          - name: TEST_VAR
            valueFrom:
                configMapKeyRef:
                    name: test-configmap
                    key: department
```

And can also populate a volume. In the following example, the `etc/config` directory is populated with the config map data.

```
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: neilpeterson/nepetersv1
      command: [ "/bin/sh", "cat /etc/config/special.how" ]
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: special-config
  restartPolicy: Never
```

A config map can also be created from file.

```
kubectl create configmap config-map-file --from-file=./config-dir/config-one.properties
```

A config map can also be created from a directory of files.

```
kubectl create configmap config-map-dir --from-file=./config-dir
```
