# Code Challenge
<!-- TOC depthfrom:2 bulletcharacter:* -->

* [Install dependencies](#install-dependencies)
    * [Terraform and nodejs via ASDF](#terraform-and-nodejs-via-asdf)
* [Building locally via Docker](#building-locally-via-docker)
* [Deploying to ECS Cluster](#deploying-to-ecs-cluster)
    * [Create ECS cluster](#create-ecs-cluster)
    * [CI/CD](#cicd)

<!-- /TOC -->

## Install dependencies

Overall you'll need the following dependencies. Installation details are in section headings below if they're not already available.

* Terraform 0.12.x
* nodejs

### Terraform and nodejs via ASDF

See installation instructions for `asdf` itself at <https://asdf-vm.com/>. Once it's installed, ensure that you have the following plugins installed:

* [terraform](https://github.com/Banno/asdf-hashicorp.git)
* [nodejs](https://github.com/asdf-vm/asdf-nodejs.git)
  * Note that there are extra steps involved for checking downloads against OpenPGP signatures from the Node.js release team. You can skip these by setting the environment variable `NODEJS_CHECK_SIGNATURES=no`

Check which plugins are installed via `asdf plugin-list`.

Install any missing plugins via `asdf plugin-add <pluginname>`.

Once all the plugins are installed, run `asdf install` to ensure that everything listed in [.tool-versions](.tool-versions) gets downloaded and installed.

## Building locally via Docker

The docker configurations are based on <https://mherman.org/blog/dockerizing-a-react-app/>.

The quickest way to build and launch the application is by running `docker-compose up -d --build` and then testing access via <http://localhost:3001/>.

Stopping the container can be done via `docker-compose stop`.

## Deploying to ECS Cluster

An ECS/Fargate cluster can be created via Terraform. The configuration is in [terraform](terraform) and is based on <https://github.com/Oxalide/terraform-fargate-example.git> but ported to Terraform 0.12.x and includes updates to support CI/CD processes.

### Create ECS cluster

Change directories to the [terraform](terraform) directory and edit the [variables.tf](terraform/variables.tf) file, updating the value for `app_image` to point to a dockerhub hosted image. If you plan on using CI/CD deployments as explained below, you can leave the default value as-is since it will be updated on the first deployment.

The Terraform AWS provider assumes credentials with appropriate permissions to build out an ECS cluster are available either via [environment variables](https://www.terraform.io/docs/providers/aws/index.html#environment-variables) or [shared credentials files](https://www.terraform.io/docs/providers/aws/index.html#shared-credentials-file).

```shell
# Initialize
terraform init

# Confirm the plan looks appropriate
terraform plan

# Create the cluster
terraform apply -auto-approve
```

After `terraform apply` it will output the URL that can be used to access the application. You can also re-retrieve it by running `terraform output service_url`.

### CI/CD

Automated CI/CD is configured by CircleCI via [.circleci/config.yaml](.circleci/config.yml).

The overall process is:

1. Build docker image.
1. Push to dockerhub.
1. Update the ECS service and task with the new docker image.

To configure CircleCI, you'll need to set the following environment variables in the project:

* AWS_REGION
* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* DOCKER_LOGIN
* DOCKER_PASSWORD