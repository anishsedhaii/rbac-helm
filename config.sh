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
        --set clusterrole.name=clusterrole-$USERNAME --set clusterrolebinding.name=clusterrole-binding-$USERNAME --set clusterrole.serviceaccount.name=$USERNAME --set clusterrole.secret.name=$USERNAME
    else
        helm upgrade $USERNAME --install roles/ --dry-run \
        --set role.namespace=$NAMESPACE --set rolebinding.name=developer-role-binding-$USERNAME --set role.serviceaccount.name=$USERNAME --set role.secret.name=$USERNAME
    fi
}


apply() {
    if [ $ROLE == "ClusterRole" ]; then
        helm upgrade $USERNAME --install roles/ \
        --set clusterrole.name=clusterrole-$USERNAME --set clusterrolebinding.name=clusterrole-binding-$USERNAME --set clusterrole.serviceaccount.name=$USERNAME --set clusterrole.secret.name=$USERNAME
    else
        kubectl get roles -n $NAMESPACE
        role=$(kubectl -n $NAMESPACE get roles -o=jsonpath='{.items[*].metadata.name}')
        if [[ $role =~ "developer-role" ]]; then
          echo "Developer role already exists. Creating rolebinding" &> /dev/null
        else
          kubectl create role developer-role --verb=* --resource=* --namespace=$NAMESPACE
        fi
        helm upgrade $USERNAME --install roles/ \
        --set role.namespace=$NAMESPACE --set rolebinding.name=developer-role-binding-$USERNAME --set role.serviceaccount.name=$USERNAME --set role.secret.name=$USERNAME
    fi
}
if [ $ACTION == "plan" ]; then
  plan
elif [ $ACTION == "apply" ]; then
  apply
else
  echo "Wrong Option !!"
fi