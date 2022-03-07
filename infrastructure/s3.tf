resource "random_string" "random" {
    length           = 4
    special          = false
}

resource "aws_s3_bucket" "blog" {
    bucket = "${random_string.random.result}-var.blog_bucket_name"
    tags   = var.global_tags
}

resource "aws_s3_bucket_public_access_block" "blog" {
    bucket              = aws_s3_bucket.blog.id
    block_public_policy = false
}

resource "aws_s3_bucket_website_configuration" "blog" {
    bucket = aws_s3_bucket.blog.bucket

    index_document {
        suffix = "index.html"
    }
}

resource "aws_s3_bucket_policy" "public_read" {
    bucket = aws_s3_bucket.blog.id
    policy = data.aws_iam_policy_document.public_read.json
}

data "aws_iam_policy_document" "public_read" {
    statement {
        principals {
            type = "*"
            identifiers = ["*"]
        }

        effect = "Allow"

        actions = [
            "s3:GetObject",
            "s3:ListBucket",
        ]

        resources = [
            "${aws_s3_bucket.blog.arn}/*",
            "${aws_s3_bucket.blog.arn}"
        ]
    }
}