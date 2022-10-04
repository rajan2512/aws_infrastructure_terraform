output "id" {
  value       = aws_efs_file_system.main[0].id
  description = "EFS ID"
}

output "efs_dns_name" {
  value       = aws_efs_file_system.main[0].dns_name
  description = "EFS DNS name"
}



# output "mount_target_ids" {
#   value       = "${aws_efs_mount_target.main.id}"
#   description = "List of EFS mount target IDs (one per Availability Zone)"
# }

output "file_system_id" {
  value       = aws_efs_file_system.main[0].id
  description = "EFS File System"
}
