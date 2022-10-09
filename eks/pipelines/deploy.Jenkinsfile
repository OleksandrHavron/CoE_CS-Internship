pipeline {
    agent any;
      
    stages {
        stage('Update kubeconfigfile'){
            steps{
                // Initialize terraform to be able to get output values
                dir("./eks/tf"){
                    sh "terraform init -no-color"
                }
                // Updating kubeconfig with cluster created by terraform
                withAWS(credentials: "Amazon creds", region: "eu-central-1"){
                    sh 'aws eks update-kubeconfig --name OleksandrHavron-cluster'
                }
            }
        }
        stage('Download env file'){
            steps{
                // Donwnolading file with environment variables
                withAWS(credentials: "Amazon creds", region: "eu-central-1"){
                    sh 'aws s3 cp s3://env-files-dca231321f31/.env.local ./eks/k8s/secrets/.env.local'
                }
            }
        }
        stage('Create resources'){
            steps{
                withAWS(credentials: "Amazon creds", region: "eu-central-1"){
                    dir('./eks/k8s'){
                        sh 'kubectl apply -f ./namespaces.yaml'
                        sh 'kubectl create configmap env --from-env-file=./secrets/.env.local --namespace=app'
                        sh 'kubectl apply -k secrets'
                        sh 'kubectl apply -f ./mongo.yaml'
                        sh 'kubectl apply -f ./postgres-storage.yaml'
                        sh 'kubectl apply -f ./postgresql.yaml'
                        sh 'kubectl apply -f ./api.yaml'
                        sh 'kubectl apply -f ./ui.yaml'
                        sh 'kubectl apply -f HPA.yaml'
                    }
                }
            }
        }    
    }
}