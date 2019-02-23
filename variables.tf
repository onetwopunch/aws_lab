variable "public_key" {
  description = "Your ssh public key so you can SSH into the instances you're creating"
}

variable "region" {
  default = "us-west-2"
}

variable "availability_zones" {
  default = ["a", "b"]
}

variable "desired_capacity" {
  description = "How many instances should spin up?"
  default = 2
}

variable "s3_bucket" {
  description = "S3 Bucket"
}

variable "s3_object" {
  description = "The object in the S3 Bucket where the ip list is stored."
}
