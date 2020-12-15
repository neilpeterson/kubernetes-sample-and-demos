# Questions

1. Create deployment in namespace, multiple replicas, with environment variable, and exposed port.

2. Create file on node (index.html), create a persistent volume (hostpath), 1Gi and ReadWriteOnce, create a persistent volume claim, 100Mi and ReadWriteOnce. Create a pod that uses the pvc, with pod label, and mount the volume in pod. 

3. YAML pod manifest, command line arguments, displayt pod summary in json and output to file.

4. CReate a secreate and cosnume in pod environment variable. 

5. Create a config and consume in pod (volume mount, environment variable).

6. Scale a deployment, and create a service to expose the deployment.

7. Get logs and store in a file.

8. Update pod with maxSurge and maxUnavaliable, perform rolling update changing image version, rollback. 

9. Create pod and expose port

10. New pod to communicate with two pods and nothing else.

11. Fund top cpu cosuming pod, name to text file.

12. Readiness and liveness probe on HTTP.

13. Create deployment that runs two containers, converts file from one formtat to another in shared volume.

14. Create chron job (yaml and imperitive).

15. See study guide.

16. Deployment failing, identify and update image.

17. Create pod that request min 200m CPU and 1Gi memory.

18. Failed liveness probe, identify pod and store name.

19. Namespace requires specific service account, update deployment to use sa.