variable "resource_group_name" {
  default = "apimanagementoffrexchange"
}
variable "location" {
  default = "France Central"
}
variable "apiname" {
  default = "apim-cityz-media-exchangeoffre"
}
variable "publisher_name" {
  default = "Cityz Media"
}
variable "publisher_email" {
  default = "mouad.elabid@cityzmedia.fr"
}
variable "custom_domain" {
  default = "exchangeofferapi.cityzmedia.tech"
}
variable "dnsrecordsetCNAME" {
  default = "exchangeofferapi"
}
variable "key_vault_id" {
  default = "/subscriptions/4101fe67-1af2-4898-86dd-af121760437f/resourceGroups/rg-sandbox-infra-acmebot/providers/Microsoft.KeyVault/vaults/kv-infra-acmebot-sbx-frc"
}
variable "products" {
  description = "List of products to create."
  type        = list(string)
  default     = []
}
variable "create_product_group_and_relationships" {
  description = "Create local APIM groups with name identical to products and create a relationship between groups and products."
  type        = bool
  default     = false
}
