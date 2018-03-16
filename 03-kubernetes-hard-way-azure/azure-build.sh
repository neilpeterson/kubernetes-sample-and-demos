#!/bin/bash

resourceGroup=kubernetesHardWay002

# Create resource group
az group create --name $resourceGroup --location eastus

# Create vnet / subnet
az network vnet create \
  --resource-group $resourceGroup \
  --name kubernetes-vnet \
  --address-prefix 10.240.0.0/24 \
  --subnet-name kubernetes-subnet 

# Create network security group
az network nsg create \
  --resource-group $resourceGroup \
  --name kubernetes-nsg

# Connect nsg to subnet
az network vnet subnet update \
  --resource-group $resourceGroup \
  --name kubernetes-subnet \
  --vnet-name kubernetes-vnet \
  --network-security-group kubernetes-nsg

# Allow SSH
az network nsg rule create \
  --resource-group $resourceGroup \
  --name kubernetes-ssh \
  --access allow \
  --destination-port-range 22 \
  --nsg-name kubernetes-nsg \
  --protocol tcp \
  --priority 1000

# Allow Kubernetes API server
az network nsg rule create \
  --resource-group $resourceGroup \
  --name kubernetes-api \
  --access allow \
  --destination-port-range 6443 \
  --nsg-name kubernetes-nsg \
  --protocol tcp \
  --priority 1001

  # Allow etcd
az network nsg rule create \
  --resource-group $resourceGroup \
  --name etcd \
  --access allow \
  --destination-port-range 2380 \
  --nsg-name kubernetes-nsg \
  --protocol tcp \
  --priority 1002

# Create NLB / PIP
az network lb create \
  --resource-group $resourceGroup \
  --name kubernetes-lb \
  --backend-pool-name kubernetes-lb-pool-cp \
  --public-ip-address kubernetes-pip \
  --public-ip-address-allocation static

az network lb address-pool create --lb-name kubernetes-lb --name kubernetes-lb-pool-node --resource-group $resourceGroup


# Creates an LB probe on port 6443
az network lb probe create --resource-group $resourceGroup --lb-name kubernetes-lb --name APIServer --protocol tcp --port 6443

# LB Rule for API Server
az network lb rule create \
  --resource-group $resourceGroup \
  --lb-name kubernetes-lb \
  --name APIServer \
  --protocol tcp \
  --frontend-port 6443 \
  --backend-port 6443 \
  --backend-pool-name kubernetes-lb-pool-cp \
  --probe-name APIServer

# Creates an LB probe on port 22
az network lb probe create --resource-group $resourceGroup --lb-name kubernetes-lb --name myHealthProbe --protocol tcp --port 22

# Create controll plane avalibility set
az vm availability-set create \
  --resource-group $resourceGroup \
  --name kubernetes-controll-as

# Create controller VMs and public ip addresses
for i in 0 1 2; do

    az network lb inbound-nat-rule create \
      --resource-group $resourceGroup \
      --lb-name kubernetes-lb \
      --name controller-${i} \
      --protocol tcp \
      --frontend-port 422$i \
      --backend-port 22
    
    az network nic create \
      --resource-group $resourceGroup \
      --name controller-${i}-nic \
      --private-ip-address 10.240.0.1${i} \
      --vnet kubernetes-vnet \
      --subnet kubernetes-subnet \
      --ip-forwarding \
      --lb-name kubernetes-lb \
      --lb-address-pools kubernetes-lb-pool-cp \
      --lb-inbound-nat-rules controller-${i}

    # Create controller vm
    az vm create \
      --resource-group $resourceGroup \
      --name controller-${i} \
      --image Canonical:UbuntuServer:16.04.0-LTS:latest \
      --nics controller-${i}-nic \
      --availability-set kubernetes-controll-as \
      --nsg '' > /dev/null

done

# Create nodes avalibility set
az vm availability-set create --resource-group $resourceGroup --name kubernetes-nodes-as

# Create nodes VMs and public ip addresses
for i in 0 1 2; do

    az network lb inbound-nat-rule create \
      --resource-group $resourceGroup \
      --lb-name kubernetes-lb \
      --name worker-${i} \
      --protocol tcp \
      --frontend-port 522$i \
      --backend-port 22
   
    az network nic create \
      --resource-group $resourceGroup \
      --name worker-${i}-nic \
      --private-ip-address 10.240.0.2${i} \
      --vnet kubernetes-vnet \
      --subnet kubernetes-subnet \
      --ip-forwarding \
      --lb-name kubernetes-lb \
      --lb-address-pools kubernetes-lb-pool-node \
      --lb-inbound-nat-rules worker-${i}
    
    az vm create \
      --resource-group $resourceGroup \
      --name worker-${i} \
      --image Canonical:UbuntuServer:16.04.0-LTS:latest \
      --nics worker-${i}-nic \
      --availability-set kubernetes-controll-as --nsg '' > /dev/null

done