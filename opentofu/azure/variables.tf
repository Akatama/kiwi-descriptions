variable "location" {
  type    = string
  default = "Central US"
}

variable "resourceGroupName" {
  type    = string
  default = "openSUSE"
}

variable "storageAccountName" {
  type        = string
  description = "The name of the storage account. The name must be globally unique"
  default     = "tumbleweedTest"
}

variable "storageAccountReplicationType" {
  type        = string
  default     = "GRS"
  description = "Valid options are LRS, GRS, RAGRS, ZRS, and RAGZRS"
}

variable "containerName" {
  type        = string
  description = "The name of the container where the VHD files will be stored"
  default     = "images"
}

variable "containerAccessType" {
  type        = string
  default     = "private"
  description = "valid values are blob, container and private"
}

variable "galleryName" {
  type    = string
  default = "TumbleweedTestGallery"
}

variable "galleryDescription" {
  type    = string
  default = "openSUSE Tumbleweed Images"
}

variable "armImageDefinitionBaseName" {
  type        = string
  description = "The base Image Defintion name for the ARM image"
}

variable "x86ImageDefinitionBaseName" {
  type        = string
  description = "The base Image Defintiion name for the x86 image"
}

variable "imageDefinitionSKU" {
  type        = string
  description = "The Image Defintiion SKU"
  default     = "tumbleweed"
}

variable "imageDefinitionGeneration2" {
  type        = string
  description = "The suffix for the generation 2 image"
  default     = "gen2"

}

variable "imageDefinitionStorageAccountType" {
  type        = string
  description = "Valid values are Standard_LRS, Premium_LRS and Standard_ZRS"
  default     = "Premium_LRS"
}

variable "eula" {
  type        = string
  description = "The EULA for the community gallery"
}

variable "prefix" {
  type        = string
  description = "Prefix of the community public name for the community gallery"
}

variable "publisherEmail" {
  type    = string
  default = "cloud-team@opensuse.org"
}

variable "publisherURI" {
  type        = string
  description = "URI of the publisher for the Shared Image Gallery"
}

