resource "random_string" "random" {
    length           = 4
    special          = false
    lower            = true
    upper            = false
    number           = false 
}

resource "aws_s3_bucket" "blog" {
    bucket = "${random_string.random.result}-${var.blog_bucket_name}"
    tags   = var.global_tags
}