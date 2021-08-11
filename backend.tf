terraform {
  backend "s3" {
    bucket = "devopsbucket-new"
    key    = "demo/instance"
    region = "us-east-2"
  }
}
