

####################### infrastructure provisionning ##########################
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

resource "null_resource" "set_env_vars" {
  provisioner "local-exec" {
    command = <<EOT
      export password=${azurerm_container_registry.acr.admin_password}
      export username_acr=${azurerm_container_registry.acr.admin_username}
    EOT
  }
}

############################execute ansible playbook#############################

resource "null_resource" "run_ansible_playbook" {
  provisioner "local-exec" {
    command = "ansible-playbook ./playbook.yml"
  }
}

#################################################################################



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


########################## install helm chart ###############################

resource "helm_release" "my_app" {
  name       = "my-release"
  repository = "../../"
  chart      = "my-char"
  namespace  = "default"
}
