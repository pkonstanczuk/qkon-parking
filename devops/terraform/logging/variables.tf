variable "log_groups" {
  type = list(string)
}

variable "log_groups_providers" {
  type = list(string)
}

variable "code_version" {
  type        = string
  description = "deployed version"
}