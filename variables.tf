variable "name" {
  type = string
}

variable "lambda_tags" {
  type    = map(string)
  default = null
}

variable "forward_logs_to_elastic" {
  type    = bool
  default = true
}

variable "alert_on_errors" {
  type    = bool
  default = true
}

// Below this line are all arguments for the Lambda which will be used directly
// Note that blocks need to be specified as objects
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function#argument-reference

variable "architectures" {
  type    = set(string)
  default = null
}

variable "code_signing_config_arn" {
  type    = string
  default = null
}

variable "dead_letter_config" {
  type = object({
    target_arn = string
  })
  default = null
}

variable "description" {
  type    = string
  default = null
}

variable "environment" {
  type = object({
    variables = map(string)
  })
  default = null
}

variable "ephemeral_storage" {
  type = object({
    size = number
  })
  default = null
}

variable "file_system_config" {
  type = object({
    arn              = string
    local_mount_path = string
  })
  default = null
}

variable "filename" {
  type    = string
  default = null
}

variable "handler" {
  type    = string
  default = null
}

variable "image_config" {
  type = object({
    command           = optional(set(string))
    entry_point       = optional(set(string))
    working_directory = optional(string)
  })
  default = null
}

variable "image_uri" {
  type    = string
  default = null
}

variable "kms_key_arn" {
  type    = string
  default = null
}

variable "layers" {
  type    = set(string)
  default = null
}

variable "memory_size" {
  type    = number
  default = null
}

variable "package_type" {
  type    = string
  default = null
}

variable "publish" {
  type    = bool
  default = null
}

variable "reserved_concurrent_executions" {
  type    = number
  default = null
}

variable "runtime" {
  type    = string
  default = null
}

variable "s3_bucket" {
  type    = string
  default = null
}

variable "s3_key" {
  type    = string
  default = null
}

variable "s3_object_version" {
  type    = string
  default = null
}

variable "source_code_hash" {
  type    = string
  default = null
}

variable "snap_start" {
  type = object({
    apply_on = string
  })
  default = null
}

variable "timeout" {
  type    = number
  default = null
}

variable "tracing_config" {
  type = object({
    mode = string
  })
  default = null
}

variable "vpc_config" {
  type = object({
    security_group_ids = set(string)
    subnet_ids         = set(string)
  })
  default = null
}

// Please do not add any arguments below this line
// Everything between this and the comment above is directly passed through to the lambda
