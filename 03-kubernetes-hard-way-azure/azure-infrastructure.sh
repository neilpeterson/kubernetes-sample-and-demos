#!/bin/bash

resourceGroup=kubernetesHardWay2

# Create resource group
az group create --name $resourceGroup --location eastus

# Create vnet / subnet
az network vnet create --resource-group $resourceGroup --name kubernetes-vnet --address-prefix 10.240.0.0/24 --subnet-name kubernetes-subnet 

# Create network security group
az network nsg create --resource-group $resourceGroup --name kubernetes-nsg

# Connect nsg to subnet
az network vnet subnet update --resource-group $resourceGroup --name kubernetes-subnet --vnet-name kubernetes-vnet --network-security-group kubernetes-nsg

# Allow SSH
az network nsg rule create --resource-group $resourceGroup --name kubernetes-ssh --access allow --destination-port-range 22 --nsg-name kubernetes-nsg --protocol tcp --priority 1000

# Allow Kubernetes API server
az network nsg rule create --resource-group $resourceGroup --name kubernetes-api --access allow --destination-port-range 6443 --nsg-name kubernetes-nsg --protocol tcp --priority 1001

# Create public IP address
az network lb create --resource-group $resourceGroup --name kubernetes-lb --backend-pool-name kubernetes-lb-pool --public-ip-address kubernetes-pip --public-ip-address-allocation static

# Create controll plane avalibility set
az vm availability-set create --resource-group $resourceGroup --name kubernetes-controll-as

# Create controller VMs and public ip addresses
for i in 0 1 2; do 
    az network public-ip create --resource-group $resourceGroup --name kubernetes-cp-${i}-pip > /dev/null
    az network nic create --resource-group $resourceGroup --name kubernetes-cp-${i}-nic --private-ip-address 10.240.0.1${i} --public-ip-address kubernetes-cp-${i}-pip --vnet kubernetes-vnet --subnet kubernetes-subnet --ip-forwarding --lb-name kubernetes-lb --lb-address-pools kubernetes-lb-pool > /dev/null
    az vm create --resource-group $resourceGroup --name kubernetes-cp-${i} --image Canonical:UbuntuServer:16.04.0-LTS:latest --nics kubernetes-cp-${i}-nic --availability-set kubernetes-controll-as --nsg '' > /dev/null
done

# Create nodes avalibility set
az vm availability-set create --resource-group $resourceGroup --name kubernetes-nodes-as

# Create nodes VMs and public ip addresses
for i in 0 1 2; do 
    az network public-ip create --resource-group $resourceGroup --name kubernetes-node-${i}-pip > /dev/null
    az network nic create --resource-group $resourceGroup --name kubernetes-node-${i}-nic --private-ip-address 10.240.0.2${i} --public-ip-address kubernetes-node-${i}-pip --vnet kubernetes-vnet --subnet kubernetes-subnet --ip-forwarding --lb-name kubernetes-lb --lb-address-pools kubernetes-lb-pool > /dev/null
    az vm create --resource-group $resourceGroup --name kubernetes-node-${i} --image Canonical:UbuntuServer:16.04.0-LTS:latest --nics kubernetes-node-${i}-nic --availability-set kubernetes-controll-as --nsg '' > /dev/null
done