# Deployment example with update and rollback

Create deployment:

```
kubectl create -f deployment.yaml
```

Items to note from deployment:

- minReadySeconds - time Kubernetes waits between pod bootup.
- type: RollingUpdate  (can also be recreate where all pods are removed before updating).
- maxSurge - max pods greater that replica count.
- maxUnavailable - max unavaliabl during update.

Update deployment:

```
kubectl set image deployment/azure-vote-front azure-vote-front=microsoft/azure-vote-front:v2
```

Get status:

```
kubectl rollout status deployment/azure-vote-front
```

Pause rollout:

```
kubectl rollout pause deployment/azure-vote-front
```

Resume rollout:

```
kubectl rollout resume deployment/azure-vote-front
```

Rollback:

```
kubectl rollout undo deployment/azure-vote-front
```

Get deployment revision history (requires --record to be useful):

```
kubectl rollout history deployment/azure-vote-front
```

To get more details on a revision:

```
kubectl rollout history deployment/azure-vote-front --revision=2
```

Roll back to a specific revision:

```
kubectl rollout undo deployment/azure-vote-front --to-revision=2
```

Continue ramp here - https://tachingchen.com/blog/kubernetes-rolling-update-with-deployment/



