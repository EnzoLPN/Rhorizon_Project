output "instance_id" {
  value       = aws_instance.bastion.id
  description = "ID de l'instance EC2 du bastion (requis pour démarrer la session SSM)"
}
