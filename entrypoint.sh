#!/bin/bash -l
# exit on any error
set -e

KUBERNETES_CERT="${INPUT_CERT}"
KUBERNETES_SERVER="${INPUT_SERVER}"
KUBERNETES_TOKEN="${INPUT_TOKEN}"
KUBERNETES_USER="default"
CONTEXT="default"
CLUSTER_NAME="default"
NAMESPACE="${INPUT_NAMESPACE}"
DEPLOYMENT="${INPUT_NAME}"
IMAGE="${INPUT_IMAGE}"
CONTAINER="${INPUT_CONTAINER}"
EXTERNAL_SECRET="${INPUT_EXTERNAL_SECRET}"

echo "${KUBERNETES_CERT}" | base64 -d >ca.crt

kubectl config set-cluster "${CLUSTER_NAME}" --server="${KUBERNETES_SERVER}" --certificate-authority=ca.crt

kubectl config set-context "${CONTEXT}" --cluster="${CLUSTER_NAME}" --user="${KUBERNETES_USER}"

kubectl config use-context "${CONTEXT}"

kubectl config set-credentials "$CONTEXT" --token="$KUBERNETES_TOKEN"

if [ "$EXTERNAL_SECRET" ]; then
  if [ ! "$EXTERNAL_SECRET" ]; then
    echo "External secret name was not defined."
    exit 1
  fi

  echo "Checking if $EXTERNAL_SECRET exists..."

  if [ "$(kubectl -n "$NAMESPACE" get es "$EXTERNAL_SECRET" -o json | jq '.status.conditions | first | .reason' | xargs)" == "SecretSynced" ]; then
    echo "$EXTERNAL_SECRET OK"
  else
    echo "$EXTERNAL_SECRET has an unvalid status, please review it"
    exit 1
  fi

  echo "Syncing secret before deployment image update..."

  kubectl -n "$NAMESPACE" annotate es "$EXTERNAL_SECRET" force-sync="$(date +%s)" --overwrite
fi

echo "Deploying to ${KUBERNETES_SERVER}"

echo "Updating ${DEPLOYMENT} in ${NAMESPACE} with ${IMAGE}..."

IFS=',' read -ra containers <<<"$CONTAINER"

for container in "${containers[@]}"; do
  kubectl -n "${NAMESPACE}" set image "deployment/${DEPLOYMENT}" "${container}=${IMAGE}"
done
