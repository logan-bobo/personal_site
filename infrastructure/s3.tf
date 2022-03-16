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

data "aws_iam_policy_document" "blog" {
    statement {
        actions   = ["s3:GetObject"]
        resources = ["${aws_s3_bucket.blog.arn}/*"]

        principals {
        type        = "*"
        identifiers = ["*"]
        }
    }
    }

resource "aws_s3_bucket_policy" "blog" {
    bucket = aws_s3_bucket.blog.id
    policy = data.aws_iam_policy_document.blog.json
}

resource "aws_s3_bucket_website_configuration" "blog" {
    bucket = aws_s3_bucket.blog.bucket

    index_document {
        suffix = "index.html"
    }

    error_document {
        key = "404.html"
    }

}