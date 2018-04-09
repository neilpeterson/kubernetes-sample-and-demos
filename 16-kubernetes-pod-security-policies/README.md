# Kubernetes Pod Security Policies

This plug-in acts on creation and modification of the pod and determines if it should be admitted based on the requested security context and the available Pod Security Policies.
 
- Admission controller to enable
- PSP itself is a Kubernetes object
- Validates configuration of pods, and only allows creation of compliant specs
 
Example Policies:
 
- Allowed volume types
- Usage and whitelisting of host paths
- Allowed Linux capabilities

## Current state of demo

I have not gotten these working. Policy is created but not applied.

Other interesting observation, it seems the PSP resource type is available in ACS / AKS, however the admission controller not enabled? Is this related?

