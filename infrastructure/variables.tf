variable "blog_bucket_name" {
    description = "Our main blog bucket where contents are served from"
    type        = string
}

variable "blog_lambda" {
    description = "The name of our main lambda function for redirects"
    type        = string
}

variable "global_tags" {
    description = "Tags that should be applied to every resrouce that is applicable"
    type        = map(string)
}

variable "domain" {
    description = "Our main domain"
    type        = string
}

variable "dns_zone_id" {
    description = "The zone ID of our main domain, note this is not meneged by this repository as it is used for multiple projects"
    type        = string
}

variable "zip_output" {
    description = "Output for our zip function"
    type        = string
    default     = "output/lambda/"
}
