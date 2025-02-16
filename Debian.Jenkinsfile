pipeline {
    agent none  // No global agent, we define agents for each stage

    stages {
        // Stage to apply terraform and build Docker image
        stage('Build Image with Terraform') {
            agent {
                label 'host-device'  // The agent that will run the Terraform code (on the host device)
            }
            steps {
                script {
                    echo 'Building Docker image using Terraform...'
                    sh '''
                        terraform init
                        terraform apply -auto-approve  # Apply the Terraform plan to build the Docker image
                    '''
                }
            }
        }

        // Stage to run tests in parallel
        stage('Run Tests in Parallel') {
            parallel {
                stage('Test 1 > New Host Check') {
                    agent {
                        label 'docker-ubuntu'  // The cloud agent (Docker host) for this parallel job
                    }
                    steps {
                        script {
                            echo 'Running tests in Container 00 (New Host Check)'
                            sh '''
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

                stage('Test 2 > Flags Check') {
                    agent {
                        label 'docker-ubuntu'  // The cloud agent (Docker host) for this parallel job
                    }
                    steps {
                        script {
                            echo 'Running tests in Container 01 (Flags Check)'
                            sh '''
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

        // Stage to destroy resources with Terraform (e.g., remove the Docker image)
        stage('Cleanup > Terraform Destroy') {
            agent {
                label 'host-device'  // Run cleanup on the host device
            }
            steps {
                script {
                    echo 'Cleaning up resources with Terraform...'
                    sh '''
                        terraform destroy -auto-approve  # Destroy Terraform-managed resources (the image)
                    '''
                }
            }
        }
    }
}
