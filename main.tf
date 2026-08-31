locals {
  env_config = {
    dev = {
      ec2_count    = 2
      bucket_count = 1
      table_count  = 1
      ami_id       = "ami-0c101f26f147fa7fd" # Amazon Linux
    }
    stg = {
      ec2_count    = 3
      bucket_count = 2
      table_count  = 2
      ami_id       = "ami-0e2c8caa4b6378d8c" # Ubuntu
    }
    prd = {
      ec2_count    = 4
      bucket_count = 3
      table_count  = 3
      ami_id       = "ami-0583d8c7a9c35822c" # RHEL
    }
  }

  current = local.env_config[terraform.workspace]
}

resource "aws_key_pair" "waqas3231" {
  key_name   = "${terraform.workspace}-waqas3231"
  public_key = file("/workspaces/terraform-project-1/waqas3231.pub")
}

resource "aws_instance" "app" {
  count         = local.current.ec2_count
  ami           = local.current.ami_id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.waqas3231.key_name
  subnet_id     = "subnet-005d4953d9734f867"

  tags = {
    Name = "${terraform.workspace}-ec2-${count.index}"
  }
}

resource "random_id" "suffix" {
  count       = local.current.bucket_count
  byte_length = 4
}

resource "aws_s3_bucket" "app" {
  count  = local.current.bucket_count
  bucket = "${terraform.workspace}-bucket-${count.index}-${random_id.suffix[count.index].hex}"
}

resource "aws_dynamodb_table" "app" {
  count        = local.current.table_count
  name         = "${terraform.workspace}-table-${count.index}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}