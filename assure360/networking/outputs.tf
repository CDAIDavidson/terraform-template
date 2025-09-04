output "vpc_id"               { value = aws_vpc.main.id }
output "public_subnet_id_a"   { value = aws_subnet.public_a.id }
output "public_subnet_id_b"   { value = aws_subnet.public_b.id }
output "alb_dns_name"         { value = aws_lb.public.dns_name }
output "ecs_cluster_name"     { value = aws_ecs_cluster.this.name }
