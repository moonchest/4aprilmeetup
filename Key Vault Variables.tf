#AKVName
variable "KVName" {
  default = ""
}

#RGName
variable "KVRGName" {
  default = ""
}

variable "Region" {
  # Region of the Key Vault
  default = "Australia East"
}

#Env Key
variable "Environment" {
  default = "kztest"
}


variable "TenantId" {
  #Azure AD Object ID
  default = ""
}

variable "KVType" {
  default = "standard" #default is standard, however premium must be used for HSM backed BYOK, such as EDP at rest encryption key
}


#Service Principal ID for Access Policy
variable "AccessPolicyOneObjectID" {
  default = ""
}

variable "AccessPolicyOneAppID" {
  default = ""
  # used when the access policy is assigned to service principals, in the vending machine, this will be the Platform SP
}

#variable "tag" {
  #define required tags here
#}

# Define IP Whitelisting CIDR
variable "IPWhitelisting" {
  default = ["1.2.3.4/32"]
}

# Define existing subnet associated with the Key Vault

variable "SubnetName" {
  default = ""
}

variable "VNETName" {
  default = ""
}

#Vnet RG
variable "VNETRG" {
  default = ""
}

data "azurerm_subnet" "KeyVault" {
  name                 = "${var.SubnetName}"
  virtual_network_name = "${var.VNETName}"
  resource_group_name  = "${var.VNETRG}"
}

output "subnet_id" {
  value = "${data.azurerm_subnet.KeyVault.id}"
}



#Additional key permissions 
variable "KeyPermissions" {
  default = ""
  #Default 
}

variable "SecretPermissions" {
  default = ""
}

variable "CertPermissions" {
  default = ""
}

#set the existing Log Analytics Workspace for the Key Vault logging
variable "LAWorkspace" {
  default = ""
}

#Log Analytics Workspace RG
variable "LAWorkspaceRG" {
  default = ""
}


variable "KVAuditName" {
  default = ""
}
