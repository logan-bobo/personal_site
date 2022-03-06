variable "blog_bucket_name" {
    description = "Out main blog bucket where contents are served from"
    type = string
}

variable "global_tags" {
    description = "Tags that should be applied to every resrouce that is applicable"
    type = map(string)
}

variable "domain" {
    description = "Our main domain"
    type = string
}