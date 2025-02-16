terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}
# Build the Docker image from the Dockerfile
resource "docker_image" "jenkins_agent" {
  name         = "jenkins-agent:latest"
  keep_locally = false
  build {
    context    = "${path.module}/Docker"                   # Use the path to the Docker directory
    dockerfile = "${path.module}/Docker/Debian.Dockerfile" # Use the path to the Dockerfile
    remove     = true
  }
}
