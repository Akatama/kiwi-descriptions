data "azurerm_resource_group" "rg" {
    name = var.resourceGroupName
}

resource "azurerm_storage_account" "sa" {
    name = var.storageAccountName
    resource_group_name = data.azurerm_resource_group.rg.name
    location = var.location
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
    resource_group_name = data.azurerm_resource_group.rg.name
    location = var.location
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
    resource_group_name = data.azurerm_resource_group.rg.name
    location =  var.location
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
    resource_group_name = data.azurerm_resource_group.rg.name
    location =  var.location
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
    resource_group_name = data.azurerm_resource_group.rg.name
    location =  var.location
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
    resource_group_name = data.azurerm_resource_group.rg.name
    location =  var.location
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
