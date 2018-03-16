#!/bin/bash

resourceGroup=kubernetesHardWay002

# Certificate Authority

cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# The Admin Client Certificate

cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:masters",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

# The Kubelet Client Certificates

EXTERNAL_IP=$(az network public-ip list --resource-group $resourceGroup --query [0].ipAddress -o tsv)

for i in 0 1 2; do
cat > ${i}-csr.json <<EOF
{
"CN": "system:node:${i}",
"key": {
    "algo": "rsa",
    "size": 2048
},
"names": [
    {
    "C": "US",
    "L": "Portland",
    "O": "system:nodes",
    "OU": "Kubernetes The Hard Way",
    "ST": "Oregon"
    }
]
}
EOF

INTERNAL_IP=$(az vm show --name kubernetes-node-${i} --resource-group $resourceGroup -d --query privateIps -o tsv)

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${i},${EXTERNAL_IP},${INTERNAL_IP} \
  -profile=kubernetes \
  ${i}-csr.json | cfssljson -bare ${i}
done

# The kube-proxy Client Certificate

cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:node-proxier",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy

# The Kubernetes API Server Certificate

cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${EXTERNAL_IP},127.0.0.1,kubernetes.default \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes


# Copy certificates to VMs

for i in 0 1 2; do
scp -P 522${i} -o StrictHostKeyChecking=no ca.pem ${i}-key.pem ${i}.pem $EXTERNAL_IP:~/
done

for i in 0 1 2; do
scp -P 422${i} -o StrictHostKeyChecking=no ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem $EXTERNAL_IP:~/
done

# Kubernetes Configuration Files for Authentication

for i in 0 1 2; do
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${i}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${i}.pem \
    --client-key=${i}-key.pem \
    --embed-certs=true \
    --kubeconfig=${i}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${i} \
    --kubeconfig=${i}.kubeconfig

  kubectl config use-context default --kubeconfig=${i}.kubeconfig
done

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy \
  --client-certificate=kube-proxy.pem \
  --client-key=kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig
  
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

for i in 0 1 2; do
scp -P 422${i} -o StrictHostKeyChecking=no ca.pem ${i}.kubeconfig kube-proxy.kubeconfig $EXTERNAL_IP:~/
done

# Data encryption config and key

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

for i in 0 1 2; do
scp -P 422${i} -o StrictHostKeyChecking=no encryption-config.yaml $EXTERNAL_IP:~/
done

# Clean up
rm *.json
rm *.csr
# rm *.pem
rm 0*
rm 1*
rm 2*
rm admin*
rm ca-*
rm kube*
rm *.kubeconfig
rm encryption-config.yaml