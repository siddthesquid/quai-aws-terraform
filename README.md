# Instructions

1. Install the AWS CLI and configure your AWS account credentials
2. Install terraform
3. Generate a new ssh-keypair with `ssh-keygen -f ./quai_id_rsa -t rsa -N ""`
4. Run `terraform init` followed by `terraform apply`
5. Find your instance's public endpoint on AWS and SSH into it with `ssh -i quai_id_rsa ec2-user@<endpoint>`
6. `cd go-quai` and change the `STATS_*` variables to the appropriate values in `network.env`.
7. Run quai following the instructions from the Quai team - `make run-full-node NAME=input_name_here PASSWORD=quainetworkbronze STATS_HOST=66.42.118.11`
