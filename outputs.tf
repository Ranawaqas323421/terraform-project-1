output "instance_ids" {
  value = aws_instance.app[*].id
}

output "bucket_names" {
  value = aws_s3_bucket.app[*].bucket
}

output "table_names" {
  value = aws_dynamodb_table.app[*].name
}
