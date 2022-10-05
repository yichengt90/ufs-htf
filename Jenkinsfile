pipeline {
    agent any

    stages {
        stage('build hpc-stack htf image') {
            steps {
                echo "build hpc-stack htf image"
                sh 'docker build -t "clouden90/ubuntu20.04-gnu9.3-hpc-stack-htf-jenkins:test" -f "${WORKSPACE}/docker/recipe/Dockerfile.ubuntu20.04-gnu9.3-hpc-stack-htf-jenkins" "${WORKSPACE}"'
            }
        }

        stage('build spack-stack htf image') {
            steps {
                echo "build spack-stack htf image"
                sh 'docker build -t "clouden90/ubuntu20.04-gnu9.3-spack-stack-htf-jenkins:test" -f "${WORKSPACE}/docker/recipe/Dockerfile.ubuntu20.04-gnu9.3-spack-stack-htf-jenkins" "${WORKSPACE}"'
            }
        }
        
        stage('test hpc-stack ufs-wm build') {
            steps {
                echo "test hpc-stack ufs-wm build"
                sh 'docker run --user root --rm clouden90/ubuntu20.04-gnu9.3-hpc-stack-htf-jenkins:test /bin/bash -c "bash ./docker/recipe/run_toy.sh"'
            }
        }

        stage('test spack-stack ufs-wm build') {
            steps {
                echo "test spack-stack ufs-wm build"
                //sh 'docker run --user root --rm clouden90/ubuntu20.04-gnu9.3-spack-stack-htf-jenkins:test /bin/bash -c "bash ./docker/recipe/run_toy.sh"'
            }
        }

        
    }
}
