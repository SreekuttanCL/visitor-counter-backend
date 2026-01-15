output "dynamodb_table_name" {
  value = aws_dynamodb_table.visitor_table.name
}

output "visitor_api_url" {
  value = aws_api_gateway_stage.prod_stage.invoke_url
}



