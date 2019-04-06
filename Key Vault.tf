provider "azurerm" {
  version = "=1.22.1"
}

#set the KeyVault Resource Group
resource "azurerm_resource_group" "KeyVault" {
  name     = "${var.KVRGName}"
  location = "${var.Region}"
}

#KeyVault Configs main body
resource "azurerm_key_vault" "KeyVault" {
  name                = "${var.KVName}"
  location            = "${var.Region}"
  resource_group_name = "${azurerm_resource_group.KeyVault.name}"
  tenant_id           = "${var.TenantId}"
  enabled_for_disk_encryption = true #mandatory encryption at rest
  
  tags {
    environment = "${var.Environment}"
  }

  #KeyVault tier, standard or premium, premium will be used for BYOK
  sku {
    name = "${var.KVType}"
  }

  #Define Service Endpoint and IP Whitelisting
    network_acls {
    default_action = "Deny"
    bypass         = "AzureServices" #Allow trusted Azure Services to bypass the firewall
    virtual_network_subnet_ids = ["${data.azurerm_subnet.KeyVault.id}"]
    ip_rules       = "${var.IPWhitelisting}"
  }

#START: Defining the Access Policy for the Platform SP
  access_policy {
    tenant_id = "${var.TenantId}"
    object_id = "${var.AccessPolicyOneObjectID}"
    application_id = "${var.AccessPolicyOneAppID}"

    key_permissions = [
      "get", "list", "update", "create"
    ]

    secret_permissions = [
      "get", "list", "set"
    ]

    certificate_permissions = [
      "get", "list", "update", "create"
    ]
  }
#END: Copy this section for additional access policies


#turn on soft delete and purge protection
#provider "local-exec" {
#  command = "az keyvault update --enable-soft-delete true --enable-purge-protection true"
#  interpreter = ["az", "--name ${var.KVName}", "--resource-group ${azurerm_resource_group.KeyVault.name}"]
#}
}

#Turn on auditing for the Key Vault

data "azurerm_log_analytics_workspace" "KeyVaultAudit" {
  name                = "${var.LAWorkspace}"
  resource_group_name = "${var.LAWorkspaceRG}"
}

output "log_analytics_workspace_id" {
  value = "${data.azurerm_log_analytics_workspace.KeyVaultAudit.workspace_id}"
}


resource "azurerm_monitor_diagnostic_setting" "audit" {
  name               = "${var.KVAuditName}"
  target_resource_id = "${azurerm_key_vault.KeyVault.id}"
  log_analytics_workspace_id = "${data.azurerm_log_analytics_workspace.KeyVaultAudit.id}"

  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
}