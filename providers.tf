terraform {
    required_providers{
        cloudflare = {
            version = "~> 2"
            source = "cloudflare/cloudflare"
        }
        aws = {
            source = "hashicorp/aws"
            version = "~> 3"
        }
    }
}