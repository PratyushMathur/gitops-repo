# App of Apps Sample

This folder contains a minimal sample for Argo CD App of Apps using ApplicationSet.

## Structure

- `bootstrap/root-app.yaml`: the parent Argo CD application.
- `apps/services-applicationset.yaml`: one ApplicationSet that generates Applications.
- `manifests/`: sample Kubernetes manifests deployed by child apps.

## How it works

1. Apply `bootstrap/root-app.yaml` in the Argo CD control plane namespace.
2. The root app syncs `app-of-apps/apps/services-applicationset.yaml`.
3. The ApplicationSet discovers service folders in `app-of-apps/manifests/*`.
4. It combines those services with Argo CD clusters that have label `gitops.argoproj.io/enabled=true`.
5. For each service x cluster pair, it generates one Argo CD Application.

## Bootstrap command

```bash
kubectl apply -n argocd -f app-of-apps/bootstrap/root-app.yaml
```

## Onboarding a new cluster

Label the Argo CD cluster secret (or cluster registration) so it is selected:

```bash
kubectl -n argocd label secret <cluster-secret-name> gitops.argoproj.io/enabled=true --overwrite
```

## Onboarding a new service

Add a new folder under `app-of-apps/manifests/<service-name>` with Kubernetes YAMLs.
No new Application CRD is needed.
