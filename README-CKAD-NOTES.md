## Links:

- CKAD Curriculum - https://github.com/cncf/curriculum/blob/master/CKAD_Curriculum_V1.18.pdf
- Test environment simulator - https://killer.sh/

## Checklist

- Basic pods (kubectl run nginx --image=nginx --restart=Never)
- Multi-container pods - kubectl run nginx --generator=run-pod/v1 --image nginx --dry-run -o yaml > mult.yaml
- Deployments - 
- Rolling updates - 
- Rollback - 
- Jobs - 
- CronJobs - 
- Labels, selectors, annotations - 
- Persistent Volumne Claims
- Config maps - 
- Security Contexts - 
- Resource requirements - 
- Secrets - 
- Service Accounts - 
- Liveness probes - 
- Readiness probes - 
- Container Logging - A
- Monitor apps in K8S - 
- Debuggin in K8S - 
- Services (kubectl run nginx --image=nginx --restart=Never --port=80)
- Network Policies - 
- Taints / Tollerations - 
- Node Selector - 
- Node affinity - 

## VI Things

- :set nu
- 87G - go to line 87
- ctrl f / b for paging
- $ - go to end of line
- A - go to end of line and edit
- I - go to front of line and edit
- u - undo

## After test

- Imperitive way to create pod (kubectl run nginx2 --generator=run-pod/v1 --image nginx)
- Share PVC volume between two pods for logging, also requires named storage class
- Refresh on network policy and how to config one pod for egress to two pods (I think this one would have involved adding a label to a pod / test)
- Chron job creation (hello every 1 min) - (k create cronjob test-job --image=busybox --schedule="*/1 * * * *" -- echo hello), can I susspend after a few executions
- Export events / errors to a text file

## Read these

- https://dev.to/aurelievache/tips-about-certified-kubernetes-application-developers-ckad-exam-287g
- (150 questions) - https://medium.com/bb-tutorials-and-thoughts/practice-enough-with-these-questions-for-the-ckad-exam-2f42d1228552
- https://github.com/twajr/ckad-prep-notes