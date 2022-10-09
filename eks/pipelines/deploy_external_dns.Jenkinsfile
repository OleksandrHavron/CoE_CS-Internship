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
        stage('Create ingress controller'){
            steps{
                withAWS(credentials: "Amazon creds", region: "eu-central-1"){
                    dir('./eks/k8s'){
                        sh 'eksctl create iamserviceaccount --name external-dns --namespace app --cluster OleksandrHavron-cluster --attach-policy-arn arn:aws:iam::815668066821:policy/AWSExternalDNSIAMPolicy --approve'
                        sh 'kubectl apply -f ./eks/k8s/external-dns.yaml'
                    }
                }
            }
        }    
    }
}