#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

version=${1:-v1alpha1}

kubectl_output="$(kubectl create configmap chainerjob-operator-$version-hooks -n metacontroller --from-file=$version-hooks --append-hash)"
echo "${kubectl_output}"
expr='configmap "(.+)" created'
if [[ "${kubectl_output}" =~ $expr ]]; then
  configmap="${BASH_REMATCH[1]}"
  patch="{\"spec\":{\"template\":{\"spec\":{\"volumes\":[{\"name\":\"hooks\",\"configMap\":{\"name\":\"${configmap}\"}}]}}}}"
  kubectl patch deployment -n metacontroller chainer-operator-$version -p "${patch}"
fi
