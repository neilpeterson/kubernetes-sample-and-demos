# Kubernetes Pod Preset

- Intercept and mutate object create or apply request.
- Enabled .via an admission controller
- Preset is applied to pods with matching label key pair.
- PodPreset itself is an api object

## Example

Adds an environment variable to all pods with the label `preset: demo`.

```
apiVersion: settings.k8s.io/v1alpha1
kind: PodPreset
metadata:
  name: allow-database
spec:
  selector:
    matchLabels:
      preset: demo 
  env:
    - name: PRESET_DEMO
      value: "Demo Preset Environment Varible.."
```

## Potential limitations / issues:

Cannot start and container to pod via. pod preset - https://github.com/kubernetes/kubernetes/issues/43874