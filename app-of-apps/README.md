# App of Apps Sample

This folder contains a minimal sample for Argo CD App of Apps using ApplicationSet.

## Structure

- `bootstrap/root-app.yaml`: the parent Argo CD application.
- `apps/services/*.yaml`: one ApplicationSet per service.
- `charts/base-service`: shared Deployment/Service templates.
- `charts/<service>`: thin service charts that depend on `base-service`.

## How it works

1. Apply `bootstrap/root-app.yaml` in the Argo CD control plane namespace.
2. The root app syncs all files in `app-of-apps/apps/` recursively.
3. Each file in `app-of-apps/apps/services/` defines one service-specific ApplicationSet.
4. Each service ApplicationSet selects clusters using service-specific labels (for example, `services.guestbook=true`).
5. It generates Applications only for matching service x cluster combinations.

## Bootstrap command

```bash
kubectl apply -n argocd -f app-of-apps/bootstrap/root-app.yaml
```

## Onboarding a new cluster

Label the Argo CD cluster secret (or cluster registration) so it is selected:

```bash
kubectl -n argocd label secret <cluster-secret-name> gitops.argoproj.io/enabled=true --overwrite
```

Enable only selected services on that cluster:

```bash
kubectl -n argocd label secret <cluster-secret-name> services.guestbook=true --overwrite
kubectl -n argocd label secret <cluster-secret-name> services.nginx=true --overwrite
kubectl -n argocd label secret <cluster-secret-name> services.whoami=true --overwrite
```

## Onboarding a new service

Add a new Helm chart under `app-of-apps/charts/<service-name>` that depends on `base-service`, and define service-specific values in `values.yaml`.
No new Application CRD is needed.
Also add a new file `apps/services/<service-name>-applicationset.yaml` that selects `services.<service-name>=true`.

Use this starter template:

`app-of-apps/templates/service-applicationset.template.yaml`

Quick workflow:

```bash
cp app-of-apps/templates/service-applicationset.template.yaml \
  app-of-apps/apps/services/payments-applicationset.yaml
# Replace all '<service-name>' with 'payments'
```

Or use the helper script to scaffold both chart and ApplicationSet:

```bash
./scripts/add-service.sh payments ghcr.io/your-org/payments 1.0.0
```

Arguments:

- `<service-name>`: required
- `[image-repository]`: optional, default `nginx`
- `[image-tag]`: optional, default `latest`

## Optional shared manifests via flags

`base-service` supports optional manifests controlled by enable flags in service values:

- `base.serviceAccount.enabled`
- `base.configMap.enabled`
- `base.ingress.enabled`
- `base.hpa.enabled`
- `base.service.enabled` (default true)
- `base.deployment.enabled` (default true)
