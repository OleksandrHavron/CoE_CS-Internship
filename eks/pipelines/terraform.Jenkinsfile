pipeline {
    agent any
    
    stages {
        stage('Terraform init/plan'){
            steps{
                dir('./OleksandrHavron/tf_files') {
                    // Initialize a working directory
                    sh 'terraform init -reconfigure -no-color'
                    // Create an execution plan
                    sh 'terraform plan -out=tfplan -no-color'
                }
            }
        }

        stage('Terraform apply'){
            steps{
                // Execute the actions proposed in a execution plan
                dir('./OleksandrHavron/tf_files') {
                    sh 'terraform apply -auto-approve tfplan -no-color'
                }
            }
        }
    }
}