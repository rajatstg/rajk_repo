terraform {
  backend "s3" {
    bucket = "devops-2021-12345"
    key    = "demo/instance"
    region = "us-east-2"
  }
}