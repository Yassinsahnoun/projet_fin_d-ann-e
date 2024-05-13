

resource "azurerm_resource_group" "groupe_azure" {
  name     = "groupe_azure"
  location = "France Central"
}



resource "azurerm_container_registry" "acr" {
  name                = "myacr24762"
  resource_group_name = azurerm_resource_group.groupe_azure.name
  location            = azurerm_resource_group.groupe_azure.location
  sku                 = "Basic"
  admin_enabled       =  true
  
}



resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "my-aks-cluster"
  location            = "France Central"
  resource_group_name = "groupe_azure"
  dns_prefix          = "myakscluster"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "test_env"
  }
}

# create role assignment for aks acr pull
resource "azurerm_role_assignment" "acr_aks" {
  principal_id                     = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}