provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name                = var.resource_group_name
  location            = var.location

}


resource "azurerm_api_management" "apim" {
  name                = var.apiname
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name  = var.publisher_name
  publisher_email = var.publisher_email
  sku_name        = "Developer_1"
  identity {
    type         = "SystemAssigned"
    }

}

data "azurerm_key_vault" "akv" {
  name                = "kv-infra-acmebot-sbx-frc"
  resource_group_name = "rg-sandbox-infra-acmebot"
}

data "azurerm_client_config" "current" {
}

data "azurerm_key_vault_certificate" "akvcerts" {
  key_vault_id = data.azurerm_key_vault.akv.id
  name                ="exchangeofferapi-cityzmedia-tech"
}

data "azurerm_key_vault_secret" "akvsecret" {
  key_vault_id = data.azurerm_key_vault.akv.id
  name                ="exchangeofferapi-cityzmedia-tech"
}

resource "azurerm_role_assignment" "akv_secrOFF" {
  scope                = data.azurerm_key_vault.akv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_api_management.apim.identity[0].principal_id
}

resource "azurerm_role_assignment" "akv_certOFF" {
  scope                = data.azurerm_key_vault.akv.id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = azurerm_api_management.apim.identity[0].principal_id
}

resource "azurerm_key_vault_access_policy" "kv_apim_policy" {
  key_vault_id = data.azurerm_key_vault.akv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_api_management.apim.identity[0].principal_id

  key_permissions = [
    "Get", "List"
  ]

  secret_permissions = [
    "Get",
    "List"
    ]

  certificate_permissions = [
    "Get",
    "List"
    ]
}

data "azurerm_dns_zone" "azDNS" {
  name                = "cityzmedia.tech"
  resource_group_name = "rg-sandbox-infra-azure-dns"
}

resource "azurerm_dns_cname_record" "cnameRSET" {
  name                = var.dnsrecordsetCNAME
  zone_name           = data.azurerm_dns_zone.azDNS.name
  resource_group_name = data.azurerm_dns_zone.azDNS.resource_group_name
  ttl                 = 300
  record             = replace(azurerm_api_management.apim.gateway_url,"https://","")
}

resource "azurerm_api_management_custom_domain" "apiCustoDomain" {
  api_management_id = azurerm_api_management.apim.id

  gateway {
    host_name    = var.custom_domain      #azurerm_dns_cname_record.cnameRSET.record              #"api.cityzmedia.tech" #azurerm_dns_cname_record.cnameRSET.record
    key_vault_id = data.azurerm_key_vault_certificate.akvcerts.versionless_secret_id
  }
}
