provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "hello-terraform" {
    ami = "ami-0747bdcabd34c712a"
    instance_type = "t2.micro"
}

resource "aws_eip_association" "eipassoc" {
    instance_id = "i-0dd4a6dbb2434bb67"
    allocation_id = "eipalloc-0a784c5662d60a119"

}