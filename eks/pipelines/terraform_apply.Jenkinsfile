pipeline {
    agent any
    
    stages {
        stage('Terraform init'){
            steps{
                dir('./eks/tf') {
                    // Initialize a working directory
                    sh 'terraform init -reconfigure -no-color'
                }
            }
        }

        stage('Terraform apply'){
            steps{
                // Execute the actions proposed in a execution plan
                dir('./eks/tf') {
                    sh 'terraform apply -auto-approve -no-color'
                }
            }
        }
    }
}