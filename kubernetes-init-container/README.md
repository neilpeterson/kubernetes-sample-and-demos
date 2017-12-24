# Kubernetes Init Containers

- Initialization container runs prior to ‘application’ container
- Useful when needing to decouple a short-lived process from a long running process

## Example

In the following example, an empty directory volume is created that will be present in both containers (init and application). The init container includes the git binary, which is used to clone a repo into the empty directory volume. Once complete, the application container is started, the cloned files are present in the empty directory volume. 

```
apiVersion: v1
kind: Pod
metadata:
  name: init-demo-app
spec:
  containers:
  - name: nepetersv1
    image: neilpeterson/nepetersv1
    ports:
    - containerPort: 80
    volumeMounts:
    - name: workdir
      mountPath: /content
  initContainers:
  - name: init-demo-init
    image: neilpeterson/git-init-container
    command:
    - "git"
    - "clone"
    - "https://github.com/neilpeterson/kubernetes-demos.git"
    - "/content"
    volumeMounts:
    - name: workdir
      mountPath: "/content"
  volumes:
  - name: workdir
    emptyDir: {}
```
