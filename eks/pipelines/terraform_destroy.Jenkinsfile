pipeline {
    agent any;
    
    stages {
        stage('Terraform init'){
            // Initialize a working directory
            steps{
                dir('./eks/tf') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform destroy'){
            // Destroy all resources
            steps{
                dir('./eks/tf') {
                    sh 'terraform apply -destroy -auto-approve -no-color'
                }
            }
        }
    }
}