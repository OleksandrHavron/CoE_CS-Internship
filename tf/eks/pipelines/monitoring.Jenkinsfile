pipeline {
    agent any
    environment{
        DD_API_KEY = credentials("datadog-key")                
    }
    
    stages {
        stage('Update kubeconfigfile'){
            steps{
                // Initialize terraform to be able to get output values
                dir("./OleksandrHavron/tf_files"){
                    sh "terraform init"
                }
                // Updating kubeconfig with cluster created by terraform
                withAWS(credentials: "Amazon creds", region: "eu-central-1"){
                    sh 'aws eks update-kubeconfig --name $(terraform -chdir="OleksandrHavron/tf_files" output -raw cluster_name)'
                }
            }
        }
        stage('Deploy datadog'){
            // Creating datadog-agent in eks cluster
            steps{
                sh 'helm repo add datadog https://helm.datadoghq.com'
                sh 'helm repo update'
                sh 'helm install datadog-agent -f OleksandrHavron/values.yaml --set datadog.site=\'datadoghq.eu\' --set datadog.apiKey=$DD_API_KEY datadog/datadog'
            }
        } 
    }
}