variable "repository_name" {
  description = "Name of the private Amazon ECR repository."
  type        = string

  validation {
    condition     = length(trimspace(var.repository_name)) > 0
    error_message = "repository_name must not be empty."
  }
}

variable "image_tag_mutability" {
  description = "Whether image tags can be overwritten."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition = contains(
      [
        "MUTABLE",
        "IMMUTABLE",
      ],
      var.image_tag_mutability,
    )

    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Enable ECR basic image scanning when an image is pushed."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type used by the ECR repository."
  type        = string
  default     = "AES256"

  validation {
    condition = contains(
      [
        "AES256",
        "KMS",
      ],
      var.encryption_type,
    )

    error_message = "encryption_type must be AES256 or KMS."
  }
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN when encryption_type is KMS."
  type        = string
  default     = null

  validation {
    condition = (
      var.encryption_type != "KMS"
      || (
        var.kms_key_arn != null
        && length(trimspace(var.kms_key_arn)) > 0
      )
    )

    error_message = "kms_key_arn must be provided when encryption_type is KMS."
  }
}

variable "max_image_count" {
  description = "Maximum number of images retained by the lifecycle policy."
  type        = number
  default     = 30

  validation {
    condition     = var.max_image_count >= 1
    error_message = "max_image_count must be at least 1."
  }
}

variable "untagged_image_retention_days" {
  description = "Number of days to retain untagged images."
  type        = number
  default     = 7

  validation {
    condition     = var.untagged_image_retention_days >= 1
    error_message = "untagged_image_retention_days must be at least 1."
  }
}

variable "force_delete" {
  description = "Allow Terraform to delete a non-empty repository."
  type        = bool
  default     = false
}
