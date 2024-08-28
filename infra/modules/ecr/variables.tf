variable "repository_map" {
  description = "Repository details"
  type = map(object({
    name = string
    repository_image_tag_mutability = string
  }))
}