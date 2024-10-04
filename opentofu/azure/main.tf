variable "location" {
    type = string
    default = "Central US"
}

variable "resourceGroupName" {
    type = string
    default = "openSUSE"
}

variable "storageAccountName" {
    type = string
    description = "The name of the storage account. The name must be globally unique"
    default = "tumbleweedTest"
}

variable "storageAccountReplicationType" {
    type = string
    default = "GRS"
    description = "Valid options are LRS, GRS, RAGRS, ZRS, and RAGZRS"
}

variable "containerName" {
    type = string
    description = "The name of the container where the VHD files will be stored"
    default = "images"
}

variable "containerAccessType" {
    type = string
    default = "private"
    description = "valid values are blob, container and private"
}

variable "galleryName" {
    type = string
    default = "TumbleweedTestGallery"
}

variable "galleryDescription" {
    type = string
    default = "openSUSE Tumbleweed Images"
}

variable "armImageDefinitionBaseName" {
    type = string
    description = "The base Image Defintion name for the ARM image"
}

variable "x86ImageDefinitionBaseName" {
    type = string
    description = "The base Image Defintiion name for the x86 image"
}

variable "imageDefinitionSKU" {
    type = string
    description = "The Image Defintiion SKU"
    default = "tumbleweed"
}

variable "imageDefinitionGeneration2" {
    type = string
    description = "The suffix for the generation 2 image"
    default = "gen2"

}

variable "imageDefinitionStorageAccountType" {
    type = string
    description = "Valid values are Standard_LRS, Premium_LRS and Standard_ZRS"
    default = "Premium_LRS"
}

variable "eula" {
    type = string
    description = "The EULA for the community gallery"
}

variable "prefix" {
    type = string
    description = "Prefix of the community public name for the community gallery"
}

variable "publisherEmail" {
    type = string
    default = "cloud-team@opensuse.org"
}

variable "publisherURI" {
    type = string
    description = "URI of the publisher for the Shared Image Gallery"
}


provider "azurerm" {
    features{}
}

resource "azurerm_resource_group" "rg" {
    location = var.location
    name = var.resourceGroupName
}

resource "azurerm_storage_account" "sa" {
    name = var.storageAccountName
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_tier = "Standard"
    account_replication_type = var.storageAccountReplicationType
}

resource "azurerm_storage_container" "container" {
    name = var.containerName
    storage_account_name = azurerm_storage_account.sa.name
    container_access_type = var.containerAccessType
}

resource "azurerm_shared_image_gallery" "computeGallery" {
    name = var.galleryName
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    description = var.galleryDescription
    sharing {
        permission = "Community"
        community_gallery {
            eula = var.eula
            prefix = var.prefix
            publisher_email = var.publisherEmail
            publisher_uri = var.publisherURI
        }
    }
}

resource "azurerm_shared_image" "armImageDefinitionV1" {
    name = "${var.armImageDefinitionBaseName}_${var.imageDefinitionSKU}"
    gallery_name = azurerm_shared_image_gallery.computeGallery.name
    resource_group_name = azurerm_resource_group.rg.name
    location =  azurerm_resource_group.rg.location
    os_type = "Linux"
    architecture = "Arm64"
    hyper_v_generation = "V1"
    identifier {
      offer = "arm1"
      publisher = "jimmy"
      sku = var.imageDefinitionSKU
    }
    trusted_launch_supported = false
    accelerated_network_support_enabled = true
}

resource "azurerm_shared_image" "armImageDefinitionV2" {
    name = "${var.armImageDefinitionBaseName}_${var.imageDefinitionSKU}_${var.imageDefinitionGeneration2}"
    gallery_name = azurerm_shared_image_gallery.computeGallery.name
    resource_group_name = azurerm_resource_group.rg.name
    location =  azurerm_resource_group.rg.location
    os_type = "Linux"
    architecture = "Arm64"
    hyper_v_generation = "V2"
    identifier {
      offer = "arm"
      publisher = "jimmy"
      sku = var.imageDefinitionSKU
    }
    trusted_launch_supported = true
    accelerated_network_support_enabled = true
}

resource "azurerm_shared_image" "x86ImageDefitionV1" {
    name = "${var.x86ImageDefinitionBaseName}_${var.imageDefinitionSKU}"
    gallery_name = azurerm_shared_image_gallery.computeGallery.name
    resource_group_name = azurerm_resource_group.rg.name
    location =  azurerm_resource_group.rg.location
    os_type = "Linux"
    architecture = "x64"
    hyper_v_generation = "V1"
    identifier {
      offer = "x86"
      publisher = "jimmy"
      sku = var.imageDefinitionSKU
    }
    trusted_launch_supported = false
    accelerated_network_support_enabled = true
}

resource "azurerm_shared_image" "x86ImageDefitionV2" {
    name = "${var.x86ImageDefinitionBaseName}_${var.imageDefinitionSKU}_${var.imageDefinitionGeneration2}"
    gallery_name = azurerm_shared_image_gallery.computeGallery.name
    resource_group_name = azurerm_resource_group.rg.name
    location =  azurerm_resource_group.rg.location
    os_type = "Linux"
    architecture = "x64"
    hyper_v_generation = "V2"
    identifier {
      offer = "x862"
      publisher = "jimmy"
      sku = var.imageDefinitionSKU
    }
    trusted_launch_supported = true
    accelerated_network_support_enabled = true
}

output "source_resource_group" {
    value = azurerm_resource_group.rg.name
}

output "source_storage_account" {
    value = azurerm_storage_account.sa.name
}

output "source_container" {
    value = azurerm_storage_container.container.name
}

output "gallery_name" {
    value = azurerm_shared_image_gallery.computeGallery.name
}

output "arm_offer_id" {
    value = var.armImageDefinitionBaseName
}

output "86_offer_id" {
    value = var.x86ImageDefinitionBaseName
}

output "image_sku" {
    value = var.imageDefinitionSKU
}

output "generation_id" {
    value = "${var.imageDefinitionSKU}_${var.imageDefinitionGeneration2}"
}
