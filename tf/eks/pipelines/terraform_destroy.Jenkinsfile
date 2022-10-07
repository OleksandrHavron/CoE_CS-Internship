pipeline {
    agent {
        label 'agent1'
    }
    
    stages {
        stage('Terraform init'){
            // Initialize a working directory
            steps{
                dir('./OleksandrHavron/tf_files') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform destroy'){
            // Destroy all resources
            steps{
                dir('./OleksandrHavron/tf_files') {
                    sh 'terraform apply -destroy -auto-approve -no-color'
                }
            }
        }
    }
}