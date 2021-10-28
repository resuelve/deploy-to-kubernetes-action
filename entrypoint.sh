#!/bin/bash -l

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

echo "${KUBERNETES_CERT}" | base64 -d > ca.crt

kubectl config set-cluster "${CLUSTER_NAME}" --server="${KUBERNETES_SERVER}" --certificate-authority=ca.crt

kubectl config set-context "${CONTEXT}" --cluster="${CLUSTER_NAME}" --user="${KUBERNETES_USER}"

kubectl config use-context "${CONTEXT}"

kubectl config set-credentials "$CONTEXT" --token="$KUBERNETES_TOKEN"

echo "Deploying to ${KUBERNETES_SERVER}"

echo "Updating ${DEPLOYMENT} in ${NAMESPACE} with ${IMAGE}..."

IFS=',' read -ra containers <<< "$CONTAINER"

for container in "${containers[@]}"; do
    kubectl -n "${NAMESPACE}" set image "deployment/${DEPLOYMENT}" "${container}=${IMAGE}"
done
