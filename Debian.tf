terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_image" "jenkins_agent" {
  name = "jenkins-agent:latest"
  build {
    context    = "./"           # The root directory where Dockerfile is located
    dockerfile = "./Dockerfile" # Path to the Dockerfile at the root
  }
  keep_locally = false
}
