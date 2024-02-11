#!/bin/bash

set -xe

ACTION=$ACTION
ROLE=$ROLE
USERNAME=$USERNAME
NAMESPACE=$NAMESPACE
export KUBECONFIG=kubeconfig.yaml
plan () {
    if [ $ROLE == "ClusterRole" ]; then
        helm upgrade $USERNAME --install roles/ --dry-run \
        --set clusterrole.name=clusterrole --set clusterrolebinding.name=clusterrole-binding --set clusterrole.serviceaccount.name=$USERNAME --set clusterrole.secret.name=$USERNAME
    else
        helm upgrade $USERNAME --install roles/ --dry-run \
        --set role.namespace=$NAMESPACE --set role.name=developer-role --set rolebinding.name=developer-role-binding--set role.serviceaccount.name=$USERNAME --set role.secret.name=$USERNAME
    fi
}


apply() {
    if [ $ROLE == "ClusterRole" ]; then
        helm upgrade $USERNAME --install roles/ \
        --set clusterrole.name=clusterrole --set clusterrolebinding.name=clusterrole-binding --set clusterrole.serviceaccount.name=$USERNAME --set clusterrole.secret.name=$USERNAME
    else
        helm upgrade $USERNAME --install roles/ \
        --set role.namespace=$NAMESPACE --set role.name=developer-role --set rolebinding.name=developer-role-binding --set role.serviceaccount.name=$USERNAME --set role.secret.name=$USERNAME
    fi
}
if [ $ACTION == "plan" ]; then
  plan
elif [ $ACTION == "apply" ]; then
  apply
else
  echo "Wrong Option !!"
fi