resource "aws_vpc_endpoint" "api"{
    vpc_id = "NEED_VPC_ID"
    service_name = "com.amazonaws.us-east-1.execute-api"
    vpc_endpoint_type = "Interface"
    
    private_dns_enabled = true
}