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
        stage('Download env file'){
            steps{
                // Donwnolading file with environment variables
                withAWS(credentials: "Amazon creds", region: "eu-central-1"){
                    sh 'aws s3 cp s3://env-files-dca231321f31/.env.local ./OleksandrHavron/src/etc/.env.local'
                }
            }
        }
        stage('Create resources'){
            steps{
                withAWS(credentials: "Amazon creds", region: "eu-central-1"){
                    sh 'kubectl create configmap env --from-env-file=OleksandrHavron/src/etc/.env.local'
                    sh 'kubectl create -f ./OleksandrHavron/k8s-yml/mongo.yaml'
                    sh 'kubectl create -f ./OleksandrHavron/k8s-yml/postgres-storage.yaml'
                    sh 'kubectl create -f ./OleksandrHavron/k8s-yml/postgresql.yaml'
                    sh 'kubectl create -f ./OleksandrHavron/k8s-yml/api.yaml'
                    sh 'kubectl create -f ./OleksandrHavron/k8s-yml/ui.yaml'
                }
            }
        }    
    }
}