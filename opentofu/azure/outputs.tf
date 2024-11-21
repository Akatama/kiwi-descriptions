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

output "eightySix_offer_id" {
    value = var.x86ImageDefinitionBaseName
}

output "image_sku" {
    value = var.imageDefinitionSKU
}

output "generation_id" {
    value = "${var.imageDefinitionSKU}_${var.imageDefinitionGeneration2}"
}
