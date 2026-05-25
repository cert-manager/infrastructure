output "folder_id" {
  description = "The folder ID (numeric)"
  value       = google_folder.folder.folder_id
}

output "name" {
  description = "The full resource name (folders/FOLDER_ID)"
  value       = google_folder.folder.name
}

output "display_name" {
  description = "The display name of the folder"
  value       = google_folder.folder.display_name
}
