pipeline {
    agent any;
    
    stages {
        stage('Terraform init'){
            // Initialize a working directory
            steps{
                dir('./tf/eks') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform destroy'){
            // Destroy all resources
            steps{
                dir('./tf/eks') {
                    sh 'terraform apply -destroy -auto-approve -no-color'
                }
            }
        }
    }
}