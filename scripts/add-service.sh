#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <service-name> [image-repository] [image-tag]"
  exit 1
fi

SERVICE_NAME="$1"
IMAGE_REPOSITORY="${2:-nginx}"
IMAGE_TAG="${3:-latest}"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHART_DIR="${REPO_ROOT}/app-of-apps/charts/${SERVICE_NAME}"
APPSET_TEMPLATE="${REPO_ROOT}/app-of-apps/apps/services/_service-applicationset.template.yaml"
APPSET_TARGET="${REPO_ROOT}/app-of-apps/apps/services/${SERVICE_NAME}-applicationset.yaml"

if [[ ! -f "${APPSET_TEMPLATE}" ]]; then
  echo "Template not found: ${APPSET_TEMPLATE}"
  exit 1
fi

if [[ -e "${CHART_DIR}" || -e "${APPSET_TARGET}" ]]; then
  echo "Service '${SERVICE_NAME}' already exists (chart or applicationset file present)."
  exit 1
fi

mkdir -p "${CHART_DIR}/templates"

cat > "${CHART_DIR}/Chart.yaml" <<EOF
apiVersion: v2
name: ${SERVICE_NAME}
description: ${SERVICE_NAME} service chart
type: application
version: 0.1.0
appVersion: "1.0.0"
dependencies:
  - name: base-service
    version: 0.1.0
    repository: file://../base-service
    alias: base
EOF

cat > "${CHART_DIR}/values.yaml" <<EOF
base:
  nameOverride: ${SERVICE_NAME}
  deployment:
    replicaCount: 1
  image:
    repository: ${IMAGE_REPOSITORY}
    tag: ${IMAGE_TAG}
    pullPolicy: IfNotPresent
  service:
    port: 80
EOF

sed "s/<service-name>/${SERVICE_NAME}/g" "${APPSET_TEMPLATE}" > "${APPSET_TARGET}"

echo "Created service scaffold:"
echo "  - ${CHART_DIR}"
echo "  - ${APPSET_TARGET}"
echo ""
echo "Next steps:"
echo "  1) (Optional) edit ${CHART_DIR}/values.yaml"
echo "  2) Label cluster secrets with services.${SERVICE_NAME}=true"
echo "  3) Commit and sync root app in Argo CD"
