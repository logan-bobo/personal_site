plan:
	terraform plan -var-file=env.tfvars -out=tfplan -input=false

apply:
	terraform apply -input=false tfplan

lint:
	terraform fmt -check

fmt:
	terraform fmt -recursive

