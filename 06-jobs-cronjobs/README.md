# Jobs and Cron Jobs

## Jobs

https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/

- restartPolicy - required with potential values of `Never` and `OnFailure`.
- backoffLimit - number of retries before considering a job failed (default is 6).
- activeDeadlineSeconds - max duration for the job, once reach pods and job terminated.

```
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
  activeDeadlineSeconds: 100
```

Parallelism can be controlled using the following specifications:

- `.spec.completions` - how many jobs need to complete in order for the job to complete.
- `.spec.parallelism` - how many jobs can concurrently run.

```
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  completions: 10
  parallelism: 5
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
```

### Job patterns

When designing job processing:

- A single job object for each process to be completed.
- A job object per process to be completed.

And then:

- A single pod per item to process.
- A single pod can process multiple items.

As well, the addition of a queuing system can influence job architecture.

## Cron Jobs

Cron job itself creates job objects

- spec.scheduler - required and takes the [cron format](https://en.wikipedia.org/wiki/Cron).
- spec.startingDeadlineSeconds - optional, deadline for starting job. If missed, job execution is counted as failed.
- spec.concurrencyPolicy - options with values of allow, forbid (skip next run), and replace (cancel current, start next).

```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: hello
spec:
  startingDeadlineSeconds: 30
  concurrencyPolicy: allow
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            args:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
```
