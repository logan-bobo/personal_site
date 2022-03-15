
resource "aws_iam_role" "blog" {
    name               = "lambda-iam-blog"
    assume_role_policy = data.aws_iam_policy_document.blog_lambda_role_assume.json
}

resource "aws_iam_policy" "blog" {
    name        = "lambda_blog_logging"
    path        = "/"
    policy      = data.aws_iam_policy_document.blog_lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "blog" {
    role       = aws_iam_role.blog.name
    policy_arn = aws_iam_policy.blog.arn
}

data "aws_iam_policy_document" "blog_lambda_role_assume" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
        type        = "Service"
        identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
        }
    }
}

data "aws_iam_policy_document" "blog_lambda_logging" {
    statement {

        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]

        resources = [
            "arn:aws:logs:*:*:*",
        ]
    }
}

resource "aws_lambda_function" "blog" {
    provider          = aws.acm_provider
    filename         = data.archive_file.blog.output_path
    function_name    = var.blog_lambda
    role             = aws_iam_role.blog.arn
    handler          = "exports"
    source_code_hash = filebase64sha256("${var.zip_output}lambda.zip")
    runtime          = "nodejs12.x"
    publish          = true
}

resource "aws_cloudwatch_log_group" "blog" {
    provider          = aws.acm_provider
    name              = "/aws/lambda/${var.blog_lambda}"
    retention_in_days = 1
}

data "archive_file" "blog" {
    type        = "zip"
    source_file = "files/lambda/main.js"
    output_path = "${var.zip_output}lambda.zip"
}