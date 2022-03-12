# Personal Site
A personal site to hold information about myself and blog posts

## Creating a automated serverless website using AWS, GitHub and Terraform.
I wanted to create a personal website where I could display information about myself and post technical writing surrounding technologies or ideas I am interested in. For me the site had to be serverless, easy to manage posts and have fully automated deployments. The advantage of this is the less time I have to spend building the website or managing servers the more time I can spend on developing my engineering skills or studying for various certifications. This first led me to `Hugo`. A lightweight static site generator written in Go that allows me to control the site through `markdown`  and a `configuration.toml` file! On build `Hugo` will publish an artifact to `public/` in your site root directory. This is the contents for your static site and where your `index.html` will be placed. In fact, it's where you are reading this post from now.

So now I have a framework. I've met some of my requirements outlined in my introduction. I still needed a serverless platform to deploy to. Amazon S3 meets the requirement in this scenario, whilst it is traditionally only used for object level cloud storage it also has a Static website hosting setting for your S3 bucket. We can store our artifact produced by `Hugo` in a bucket and have S3 serve the contents. This works because the contents of this bucket are static web content. Anything that utilizes server-side processing such as PHP or Python would not be usable with this feature. 

For deployments I can use the same platform where I am storing the source code for this website, GitHub. I can use the actions feature of GitHub to create automations that will run our `Hugo` build and then push our contents to our S3 Bucket. 

During our deployment I also want to deploy our infrastructure then deploy our content to the bucket. For this I opted for Terraform, a widley popular infrastructure as code tool to manage my resources in AWS via code. This give us the advantage of having the configuration of our entire infrastucutre sotred in a version controll system. Then from this we can execute automations to deploy our configurations programitaclly. Also giving us the advantage of rebuilding the entire configuration at any point, itterate on changes faster and taking advantage of terraforms build in idempotency. 

![arch](images/arch.png)

## Installing and configuring Hugo
I needed to install Hugo and its dependency `Go`.
- Install [Go](https://go.dev/doc/install).
- Install [Hugo](https://gohugo.io/getting-started/installing/).

After installing hugo and configuring my theme by adding several configurations to my `config.toml` in the root of the site.  I am able to write posts in  `markdown`, this is made even easier by running `hugo new posts/post.md`. Then test the configurations with `hugo serve` and run the site locally on the default hugo port so when I navigate to `127.0.0.1:1313` I am presented with my site with my first post.

### First result
As you can see from the minimal setup I have the ability to post content to my site with a nice theme.
![first-site](images/frist-ss.png)

## Building out the infrastrcuture

As defined in the architechure diagram above, everything in the blue box we are going to be deploying using terraform.

- S3 bucket
- Cloud Front distrobution 
- Route53 DNS records
- Certificate Manager

#### Getting Started with Terraform

The first task here is to [install terraform](https://go.dev/doc/install). When we have installed terraform and verified with `terraform -version` we can continue. To start we will strucutre the files to group resrouces that deploy resrouces for that service. 
```bash 
.
├── certificate_manager.tf
├── cloud_front.tf
├── env.tfvars
├── main.tf
├── route_53.tf
├── s3.tf
└── variables.tf
```
You can see here that there that there are some files that are not represented by `AWS` services.
- main.tf - Where we will store our state file and provider configurations.
- variables.tf - Where we will declare all of our terraform variables with their type contraints and defaults. 
- env.tfvars - Setting the values that corespond to our variables declared in variables.tf

In our `main.tf` we will need to configure our backend where our state file will be stored. The state file is used as a srouce of truth between your resrouces that are deployed and resrouces declared as a part of your configuration. When we create a resrouces as a part of our code terraform, will sotre the configuration for that resource in the state file. In this instance we have already created an S3 bucket in `AWS` that will host the state file.

```HCL
terraform {
    backend "s3" {
        bucket = "logancox-blog-terraform"
        region = "eu-west-1"
        key    = "state/main"
    }
}
```

To declare variables in terraform we will use a `variables.tf` file a good example will be the bucket name where we will host our build. We set the type to string and add a description, I will not add a default here as I know we are passing in a `tfvars` file and `S3` buckets must be globaly unique (we will add a prefix when we create the bucket).

```HCL
variable "blog_bucket_name" {
    description = "Our main blog bucket where contents are served from"
    type        = string
}
```

Finaly we set the value of the variable in the `tfvars` file

```
blog_bucket_name = "logan-cox-blog-artifacts"
```

### Building the S3 Bucket

The place we are going to host our website is our S3 bucket so frist we will need to create a bucket with a random prefix to ensure it is globaly unique. We will define the name and tags we wish to apply to the bucket.

```HCL
resource "random_string" "random" {
    length           = 4
    special          = false
}

resource "aws_s3_bucket" "blog" {
    bucket = "${random_string.random.result}-var.blog_bucket_name"
    tags   = var.global_tags
}
```

Next we need to ensure that our bucket is publicly accessible by turing off the public access block. We ensure this is attached to our blog bucket by refferencing the ID this also ensures that terraform can draw its dependency graph correctly. This is a hugley important thing to take in to consideration when writing any terraform configurations. 

```HCL
resource "aws_s3_bucket_public_access_block" "blog" {
    bucket              = aws_s3_bucket.blog.id
    block_public_policy = false
}
```

Now we need to add a bucket policy that will allow public read on our bucket so the public can access the contents. Again we refference values that will be generated by other resrouces so they are created in the correct order.

```HCL
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
```

Finnaly we need to configure our S3 bucket to server static web contents and reference our `index.html` docuemnt that will be uploaded to the bucket via our deployment pipeline. 

```HCL
resource "aws_s3_bucket_website_configuration" "blog" {
    bucket = aws_s3_bucket.blog.bucket

    index_document {
        suffix = "index.html"
    }
}
```

### Building out the CloudFront Distrobution

### Working with Certificate Manager

### Setting up Route 53

### Building out the CloudFront Distrobution

## Building our pipeline


