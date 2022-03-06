# Personal Site
A personal site to hold information about myself and blog posts

## Creating a automated serverless website using AWS, GitHub and Terraform.
I wanted to create a personal website where I could display information about myself and post technical writing surrounding technologies or ideas I am interested in. For me the site had to be serverless, easy to manage posts and have fully automated deployments. The advantage of this is the less time I have to spend building the website or managing servers the more time I can spend on developing my engineering skills or studying for various certifications. This first led me to `Hugo`. A lightweight static site generator written in Go that allows me to control the site through `markdown`  and a `configuration.toml` file! On build Hugo will publish an artifact to `public/` in your site root directory. This is the contents for your static site and where your `index.html` will be placed. In fact, it's where you are reading this post from now.

So now I have a framework. I've met some of my requirements outlined in my introduction. I still needed a serverless platform to deploy to. Amazon S3 meets the requirement in this scenario, whilst it is traditionally only used for object level cloud storage it also has a Static website hosting setting for your S3 bucket. We can store our artifact produced by Hugo in a bucket and have S3 serve the contents. This works because the contents of this bucket are static web content. Anything that utilizes server-side processing such as PHP or Python would not be usable with this feature. 

For deployments I can use the same platform where I am storing the source code for this website, GitHub. I can use the actions feature of GitHub to create automations that will run our Hugo build and then push our contents to our S3 Bucket. 

During our deployment I also want to deploy our infrastructure then deploy our content to the bucket. For this I opted for Terraform, a widley popular infrastructure as code tool to manage my resources in AWS via code. This give us the advantage of having the configuration of our entire infrastucutre sotred in a version controll system. Then from this we can execute automations to deploy our configurations programitaclly. Also giving us the advantage of rebuilding the entire configuration at any point, itterate on changes faster and taking advantage of terraforms build in idempotency. 

![arch](images/arch.png)

## Installing and configuring Hugo
I needed to install Hugo and its dependency `go`.
- Install [Go](https://go.dev/doc/install).
- Install [Hugo](https://gohugo.io/getting-started/installing/).

After installing hugo and configuring my theme by adding several configurations to my `config.toml` in the root of the site.  I am able to write posts in  `markdown`, this is made even easier by running `hugo new posts/post.md`. Then test the configurations with `hugo serve` and run the site locally on the default hugo port so when I navigate to `127.0.0.1:1313` I am presented with my site with my first post.

### First result
As you can see from the minimal setup I have the ability to post content to my site with a nice theme.
![first-site](images/frist-ss.png)

## Building out the infrastrcuture

### Getting Started with Terraform

#### What is the state file

#### Providers

#### The plan and apply cycle

#### Idempotency

### Building the S3 Bucket

### Building out the CloudFront Distrobution

### Working with Certificate Manager

### Setting up Route 53

## Building our pipeline


