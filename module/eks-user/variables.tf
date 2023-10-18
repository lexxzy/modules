variable "username" {
  type    = list(any)
}

variable "env" {
  type    = list(any)
  default = ["Development", "Production"]
}

variable "tags" {
  type = map(string)
  default = {
    Env = "Production"
  }
}
variable "region" {
  type = string
  default = "us-east-1"
}
variable "groups" {
  type = list(string)
}
