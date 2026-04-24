# App of Apps Sample

This folder contains a minimal sample for the Argo CD App of Apps pattern.

## Structure

- `bootstrap/root-app.yaml`: the parent Argo CD application.
- `apps/`: child Argo CD applications managed by the parent.
- `manifests/`: sample Kubernetes manifests deployed by child apps.

## How it works

1. Apply `bootstrap/root-app.yaml` in the Argo CD control plane namespace.
2. The root app syncs everything in `app-of-apps/apps`.
3. Each child app syncs its own path in `app-of-apps/manifests`.

## Bootstrap command

```bash
kubectl apply -n argocd -f app-of-apps/bootstrap/root-app.yaml
```
