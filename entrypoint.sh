#!/bin/sh

test -z "$1" && exit 1

export KUBECONFIG=/tmp/kubeconfig
kubectl config set-cluster k8s --server="https://kubernetes.default.svc"
kubectl config set clusters.k8s.certificate-authority-data $(cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt | base64 | tr -d '\n')
kubectl config set-credentials user --token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
kubectl config set-context default --cluster=k8s --user=user
kubectl config use-context default

NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
POD=$(kubectl get pods -n "${NAMESPACE}" --field-selector status.phase=Running -ojsonpath="{..metadata.name}" | tr -s " " "\n" | grep "$1" | head -1)
shift

exec kubectl exec -n "${NAMESPACE}" "${POD}" "$@"
