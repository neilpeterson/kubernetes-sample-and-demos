# Kubernetes services

Abstraction that defines a logical set of pods and policy by which to access them (service > pod.via label selector).

## Service types

- ClusterIP: exposes the service on a cluster internal IP. Only reachable inside the cluster, this is the default service type.
- NodePort - exposes on the nodes IP at a static port. This also creates a ClusterIP service, the app can be accessed on either.
- LoadBalancer - exposed externally using cloud providers load balancer.
- ExternalName - Maps service to contents of external name by returning CNAME record.

It is possible to create a service without a pod label selector. In these cases and endpoint will not be created, you can create your own.

```
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
---
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
```