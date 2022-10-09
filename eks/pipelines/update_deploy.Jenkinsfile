pipeline {
    agent {
        label 'agent1'
    }
      
    stages {
        stage('Update kubeconfigfile'){
            steps{
                // Initialize terraform to be able to get output values
                dir("./OleksandrHavron/tf_files"){
                    sh "terraform init -no-color"
                }
                // Updating kubeconfig with cluster created by terraform
                withAWS(credentials: "Amazon creds", region: "eu-central-1"){
                    sh 'aws eks update-kubeconfig --name $(terraform -chdir="OleksandrHavron/tf_files" output -raw cluster_name)'
                }
            }
        }
        stage('Update images'){
            steps{
                withAWS(credentials: "Amazon creds", region: "eu-central-1"){
                    sh 'kubectl set image deployment api api=api:latest'
                    sh 'kubectl set image deployment ui ui=ui:latest'
                }
            }
        }    
    }
}