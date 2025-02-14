pipeline {
    agent none
    stages {
        stage('Run Commands on Host > Start') {
            agent {
                label 'host-device'
            }
            steps {
                script {
                    echo 'Jenkins Host: Spinning up a container'
                    sh '''
                        docker run -d --rm -p 2000:22 \
                        --name Jenkins-Agent-Ubuntu \
                        jenkins-agent
                    '''
                }
            }
        }
        stage('Run Commands on Docker-Ubuntu > New Host Check') {
            agent {
                label 'docker-ubuntu'
            }
            steps {
                script {
                    echo 'Cloning the GitHub Repository.'
                    sh '''
                        git clone https://github.com/aniketrath/scripts.git
                        cd scripts
                        echo "Switching to the test branch"
                        git checkout test

                        # Use sed to comment out the install of gnome-tweaks and extensions
                        sed -i 's/^.*gnome-tweaks.*$/# &/' deb-setup.sh
                        sed -i 's/^.*gnome-shell-extensions.*$/# &/' deb-setup.sh
                        sed -i 's/^.*github-desktop.*$/# &/' deb-setup.sh

                        echo "Executing Script"
                        ./deb-setup.sh --setup
                    '''
                }
            }
        }
        stage('Cleanup > Setup CleanUp') {
            agent {
                label 'host-device'
            }
            steps {
                script {
                    echo 'Initiating cleanup'
                    sh '''
                        docker stop Jenkins-Agent-Ubuntu || echo "Container already stopped."
                    '''
                    echo 'Cleanup Complete'
                }
            }
        }
        stage('Run Commands on Host > Flags') {
            agent {
                label 'host-device'
            }
            steps {
                script {
                    echo 'Jenkins Host: Spinning up a container'
                    sh '''
                        docker run -d --rm -p 2000:22 \
                        --name Jenkins-Agent-Ubuntu \
                        jenkins-agent
                    '''
                }
            }
        }
        stage('Run Commands on Docker-Ubuntu > Flag Check') {
            agent {
                label 'docker-ubuntu'
            }
            steps {
                script {
                    echo 'Cloning the GitHub Repository.'
                    sh '''
                        git clone https://github.com/aniketrath/scripts.git
                        cd scripts
                        echo "Switching to the test branch"
                        git checkout test

                        # Use sed to comment out the install of gnome-tweaks and extensions
                        sed -i 's/^.*gnome-tweaks.*$/# &/' deb-setup.sh
                        sed -i 's/^.*gnome-shell-extensions.*$/# &/' deb-setup.sh
                        sed -i 's/^.*github-desktop.*$/# &/' deb-setup.sh

                        echo "Executing Script"
                        ./deb-setup.sh --patch --install-docker --install-kubernetes --install-jenkins --set-alias --install-extra
                    '''
                }
            }
        }
        stage('Cleanup > Closing') {
            agent {
                label 'host-device'
            }
            steps {
                script {
                    echo 'Initiating cleanup'
                    sh '''
                        docker stop Jenkins-Agent-Ubuntu || echo "Container already stopped."
                    '''
                    echo 'Cleanup Complete'
                }
            }
        }
    }
}
