pipeline {
    agent none  // No global agent, we will define agents for each stage

    stages {
        stage('Setup > Terraform Init') {
            agent {
                label 'host-device'  // Assuming this is a host-based agent
            }
            steps {
                script {
                    echo 'Setting up Terraform environment'
                    sh 'pwd'  // Debugging step to print current directory
                    sh 'terraform init'  // Initialize Terraform
                }
            }
        }

        stage('Build Docker Image with Terraform') {
            agent {
                label 'host-device'  // Run Terraform on the host machine
            }
            steps {
                script {
                    echo 'Building Docker image using Terraform'
                    sh '''
                        terraform apply -auto-approve
                    '''  // Terraform apply to build the Docker image
                }
            }
        }

        stage('Run Tests in Parallel') {
            parallel {
                stage('Run Tests Container 00') {
                    agent {
                        label 'docker-ubuntu'  // Use the docker-ubuntu cloud agent for this stage
                    }
                    steps {
                        script {
                            echo 'Running tests in Container 00'
                            sh '''
                                # Run test scripts inside Docker container
                                git clone https://github.com/aniketrath/scripts.git
                                cd scripts
                                git checkout test
                                cd Debian-Setup

                                sed -i 's/^.*gnome-tweaks.*$/# &/' deb-setup.sh
                                sed -i 's/^.*gnome-shell-extensions.*$/# &/' deb-setup.sh
                                sed -i 's/^.*github-desktop.*$/# &/' deb-setup.sh

                                ./deb-setup.sh --setup
                            '''
                        }
                    }
                }
                stage('Run Tests Container 01') {
                    agent {
                        label 'docker-ubuntu'  // Use the docker-ubuntu cloud agent for this stage
                    }
                    steps {
                        script {
                            echo 'Running tests in Container 01'
                            sh '''
                                # Run test scripts inside Docker container
                                git clone https://github.com/aniketrath/scripts.git
                                cd scripts
                                git checkout test
                                cd Debian-Setup

                                sed -i 's/^.*gnome-tweaks.*$/# &/' deb-setup.sh
                                sed -i 's/^.*gnome-shell-extensions.*$/# &/' deb-setup.sh
                                sed -i 's/^.*github-desktop.*$/# &/' deb-setup.sh

                                ./deb-setup.sh --patch --install-docker --install-kubernetes --install-jenkins --set-alias --install-extra
                            '''
                        }
                    }
                }
            }
        }

        stage('Cleanup > Wait Before Destroying Image') {
            agent {
                label 'host-device'  // Run cleanup on the host machine
            }
            steps {
                echo "Waiting for 15 seconds before destroying the Docker image..."
                sleep(time: 15, unit: 'SECONDS')
            }
        }

        stage('Cleanup > Gracefully Stop and Destroy Resources') {
            agent {
                label 'host-device'  // Run cleanup on the host machine
            }
            steps {
                script {
                    echo 'Gracefully stopping containers using the image...'

                    // Gracefully stop the containers that are using the image
                    sh '''
                        # Get container IDs for containers using the 'jenkins-agent:latest' image
                        container_ids=$(docker ps -q --filter "ancestor=jenkins-agent:latest")

                        if [ -n "$container_ids" ]; then
                            echo "Stopping containers gracefully..."
                            docker stop $container_ids
                            echo "Containers stopped successfully"

                            echo "Removing containers..."
                            docker rm $container_ids
                            echo "Containers removed successfully"
                        else
                            echo "No containers found using the image"
                        fi
                    '''

                    echo 'Destroying Terraform resources'
                    // Run terraform destroy to remove the Docker image
                    sh '''
                        terraform destroy -auto-approve  # Clean up Terraform-managed resources (the image)
                    '''

                    echo 'Cleanup Complete'
                }
            }
        }
    }
}
