---
title: "Securing your public ALB as a CloudFront Origin with Terraform"
date: "2023-06-01"
draft: flase
tags: ["AWS", "Cloud", "Terraform"]
---

## What is the problem?

There are situations where you want to front your public-facing service with a content distribution network (CDN) in this case CloudFront. This is so you can cache content on “the edge” meaning it is closer to your users. 

You then need to distribute traffic across a series of auto-scaling instances using a load balancer in this case an AWS Application Load Balancer (ALB), this allows you to scale your instances based on traffic behind the load balancer and have them auto-register as targets. 

The problem is if you wish to use an ALB as an origin with CloudFront. The ALB hostname must resolve to a public IP address. This means that there are two endpoints for our service exposed to the web. This is a problem as if users or an attacker can hit our ALB we completely negate the effects of a CDN along with other inherit benefits of CloudFront. As CloudFront has in-built AWS Shield you automatically get:

- always-on network flow monitoring, which inspects incoming traffic and applies a combination of traffic signatures, anomaly algorithms, and other analysis techniques to detect malicious traffic in real-time.
- Automated mitigation techniques are built into AWS Shield Standard, giving underlying AWS services protection against common, frequently occurring infrastructure attacks. Automatic mitigations are applied inline to protect AWS services, so there is no latency impact.

In summary, we only want traffic directed through a single publicly routable endpoint, CloudFront, to get the benefit of caching content on the edge and in-built DDoS protection from CloudFront/AWS Shield. 

Example Architecture:

![](/posts/secure_alb/arch.png)

## How do you achieve this

Restrict inbound connections on your ALB and CloudFront to only HTTPS. This means all traffic between the user, CF, and then the ALB is encrypted.

Terraform config CloudFront origin

```HCL
origin = {
      domain_name = "origin_domain"
      custom_origin_config = {
        http_port              = 80 // Required to be set but not used
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2", "TLSv1.3"]
      }
```

Only set a HTTPS listener on your ALB

```HCL
resource "aws_lb_listener" "https" {                                                                                    
  load_balancer_arn = ""                                                                          
  port              = "443"                                                                                             
  protocol          = "HTTPS"                                                                                           
  ssl_policy        = ""                                                                
  certificate_arn   = ""             
                                                                                                                        
  default_action {                                                                                                      
    type = "fixed-response"                                                                                             
                                                                                                                        
    fixed_response {                                                                                                    
      content_type = "text/plain"                                                                                       
      status_code  = "204"                                                                                              
    }                                                                                                                   
  }                                                                                                                     
}
```

Only allow inbound HTTPS connections from the CloudFront IP list to the ALB using a Security Group.

```HCL
data "aws_ec2_managed_prefix_list" "cloudfront_prefix_list" {                      
  name = "com.amazonaws.global.cloudfront.origin-facing"                           
}                                                                                  
                                                                                   
resource "aws_security_group_rule" "cloudfront_security_groups_from_prefix_list" { 
  security_group_id = ""                    
  type              = "ingress"                                                    
  protocol          = "tcp"                                                        
  from_port         = 443                                                          
  to_port           = 443                                                          
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront_prefix_list.id] 
}

```

Add a custom HTTP header to origin requests from CloudFront. This will be considered a secret.

```HCL
custom_header = [
        {
          name : "X-Allow",
          value : "super_secret_token" // Please inject not set in clear text
        }
      ]
```

Only allow inbound connections to the ALB that contain a specific HTTP header that was added from the step above.

```HCL
resource "aws_lb_listener_rule" "example" {            
  listener_arn = aws_lb_listener.https.arn                   
                                                             
  action {                                                   
    type             = "forward"                             
    target_group_arn = aws_lb_target_group.example.arn 
  }                                                          
                                                             
  condition {                                                
    host_header {                                            
      values = [                                             
        aws_route53_record.example.name        
      ]                                                      
    }                                                        
  }                                                          
                                                             
  condition {                                                
    http_header {                                            
      http_header_name = "X-Allow"                           
      values           = ["super_secret_token"] // Please inject not set in clear text              
    }                                                        
  }                                                          
}
```

## Summary

We have secured our public ALB so it is only accessible via our CloudFront distribution. This has been done by encrypting traffic between CF and the ALB. Attaching a custom HTTP header in the origin request as a secret token, then the ALB will only forward requests that contain the secret token. Finally, the ALB will only respond to requests that have come from a dedicated list of CF distribution IPs. This protects us at multiple layers of the OSI model, at the IP level (layer 3) by restricting traffic based on origin IP and at the HTTP level (layer 7) by inspecting the HTTP header

The vulnerabilities in this solution are if your “X-Allow” header is compromised via brute force, this is very unlikely but not impossible but even then if the source IP of the request is not in the CloudFront allowed list of IPs the traffic is not forwarded.
