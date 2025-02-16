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
  name = "jenkins-agent:latest"
  build {
    context      = "./Docker"                   # The directory containing the Dockerfile
    dockerfile   = "./Docker/Debian.Dockerfile" # Path to the Dockerfile
    keep_locally = false
  }
}
