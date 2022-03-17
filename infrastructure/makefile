plan:
	terraform plan -var-file=env.tfvars -out=tfplan -input=false

apply:
	terraform apply -input=false tfplan

lint:
	terraform fmt -check -diff

fmt:
	terraform fmt -recursive

destroy:
	terraform destroy -var-file=env.tfvars

init:
	terraform init

validate:
	terraform validate


