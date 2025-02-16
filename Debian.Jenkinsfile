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

        stage('Cleanup > Destroy Resources') {
            agent {
                label 'host-device'  // Run cleanup on the host machine
            }
            steps {
                script {
                    echo 'Destroying Terraform resources'
                    sh '''
                        terraform destroy -auto-approve  # Clean up Terraform-managed resources (the image)
                    '''
                    echo 'Cleanup Complete'
                }
            }
        }
    }
}
