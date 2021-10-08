provider "aws" {
    region = var.aws_region
}

provider "cloudflare"{}

#Spinning S3 bucket with attached policy provided in json format below
resource "aws_s3_bucket" "hello-terraform" {
    bucket = var.domain_name
    acl = "public-read"
    
    website {
        index_document = "index.html"
        error_document = "index.html"
    }
}

# Routuing WWW traffic to new subdomain created by cloudflare
resource "aws_s3_bucket" "www" {
    bucket = "www.${var.domain_name}"
    acl = "public-read"
    policy = ""

    website {
        redirect_all_requests_to = "https://${var.domain_name}"
    }
}

#Creating bucket policy to apply Public: Read All to S3 bucket spun starting on line 8
resource "aws_s3_bucket_policy" "public-read" {
    bucket = aws_s3_bucket.hello-terraform.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "PublicReadHGetObject"
                Effect = "Allow"
                Principal = "*"
                Action = "s3:GetObject"
                Resource = [
                    aws_s3_bucket.hello-terraform.arn,
                    "${aws_s3_bucket.hello-terraform.arn}/*",
                ]
            },
        ]
    })
}

#Creating zone records for sweetbox.dev (var.domain_name) using cloudflare.
data "cloudflare_zones" "domain" {
    filter {
        name = var.domain_name
    }
}
resource "cloudflare_record" "site_cname" {
    zone_id = data.cloudflare_zones.domain.zones[0].id
    name = var.domain_name
    value = aws_s3_bucket.hello-terraform.website_endpoint
    type = "CNAME"
}

resource "cloudflare_record" "www" {
    zone_id = data.cloudflare_zones.domain.zones[0].id
    name = "www"
    value = var.domain_name
    type = "CNAME"

    ttl = 1
    proxied = true
}

