#!/bin/bash

set -xe

ROLE=$ROLE
MASTER_IP=$MASTER_IP
USERNAME=$USERNAME
NAMESPACE=$NAMESPACE
export KUBECONFIG=kubeconfig.yaml

token_clusterrole(){
  USER_TOKEN=$(kubectl describe secrets "$USERNAME" -n kube-system | awk '/token:/ {print $2}')
}
token_role() {
  USER_TOKEN=$(kubectl describe secrets "$USERNAME" -n "$NAMESPACE" | awk '/token:/ {print $2}')
}
generate_kubeconfig() {
CERTIFICATE=$(kubectl config view --flatten --minify=true -o=jsonpath='{.clusters[].cluster.certificate-authority-data}')
    cat <<EOF > kubeconfig_user.yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $CERTIFICATE
    server: https://$MASTER_IP:6443 #clusterendpoint
  name: $MASTER_IP #clustername
contexts:
- context:
    cluster: $MASTER_IP #clustername
    user: $USERNAME #service-account
  name: default #clustername
current-context: default
kind: Config
users:
- name: $USERNAME #service-account
  user:
    token: $USER_TOKEN
EOF

    echo "kubeconfig file generated successfully!"
}

if [ $ROLE == "ClusterRole" ]; then
  token_clusterrole
else
  token_role
fi
generate_kubeconfig