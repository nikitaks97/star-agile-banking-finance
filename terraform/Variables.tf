variable "region" {
   default = "us-east-1"
}

variable "access_key" {

   default = ""
}

variable "secret_key" {

   default = ""
}

variable "amiid" {
   default ="ami-005fc0f236362e99f"

}

variable "instance_type" {
   default = "t2.micro"
}

variable "env" {
   default = "dev"
}