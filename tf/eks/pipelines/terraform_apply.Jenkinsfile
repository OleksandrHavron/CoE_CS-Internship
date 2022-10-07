pipeline {
    agent any
    
    stages {
        stage('Terraform init'){
            steps{
                dir('./tf/eks') {
                    // Initialize a working directory
                    sh 'terraform init -reconfigure -no-color'
                }
            }
        }

        stage('Terraform apply'){
            steps{
                // Execute the actions proposed in a execution plan
                dir('./tf/eks') {
                    sh 'terraform apply -auto-approve -no-color'
                }
            }
        }
    }
}