# Splunk Log Hunting
This terraform configuration and repository is designed to quickly setup and start testing 
threat hunting in logs using Splunk.

Three servers are spun up.

* Splunk server to ingest host logs
* Vulnerable host running multiple vulnerable docker images
* Kali Box to serve as the attacker

# Requirements
* Terraform
* Digital Ocean API key

Install terraform for your machine according to the documentation

Generate SSH key for the project
`ssh-keygen`

Call the key what you would like, in this example id_rsa_terraform_splunk
and leave the passphrase empty for now.

Add the following to `.bash_profile`

```
export TF_VAR_DO="<DO_API_KEY>"
export TF_VAR_PRIVATE="<path_to_key>/id_rsa_terraform_splunk"
export TF_VAR_PUBLIC="<path_to_key>/id_rsa_terraform_splunk.pub"

```

where `<DO_API_KEY>` is your Digital Ocean API key.
And then run `source ~/.bash_profile` to enable the changes.

You can then run `terraform init`, `terraform plan`, `terraform apply` to build each server.
