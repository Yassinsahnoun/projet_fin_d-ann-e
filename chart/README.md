# create cluster :
az aks create --resource-group mygroup --name akscluster --node-count 1 --node-vm-size Standard_B2s
# connecte to the aks cluster 
# create container registry :
az acr create --resource-group mygroup --name $ACRNAME --sku Basic
# match the container registry with the cluster :
az aks update -n akscluster -g mygroup --attach-acr yassin
# create nginx-controller : 

# apply helm chart : 
helm dependency build
helm install my-project .

## helm install <release-name> .
