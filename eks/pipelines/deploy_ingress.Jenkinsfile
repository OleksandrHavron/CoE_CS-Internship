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
                    sh 'aws eks update-kubeconfig --name $(terraform -chdir="OleksandrHavron/tf_files" output -raw cluster_name)'
                }
            }
        }
        stage('Create ingress controller'){
            steps{
                withAWS(credentials: "Amazon creds", region: "eu-central-1"){
                    dir('./eks/k8s'){
                        sh 'kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"'
                        sh 'eksctl create iamserviceaccount  --cluster OleksandrHavron-cluster --namespace kube-system --name aws-load-balancer-controller --attach-policy-arn arn:aws:iam:::policy/AWSLoadBalancerControllerIAMPolicy --override-existing-serviceaccounts --approve'
                        sh 'kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"'
                        sh 'helm repo add eks https://aws.github.io/eks-charts'
                        sh 'helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=OleksandrHavron-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set image.tag="v2.4.1" --version="1.4.1"'
                        sh 'kubectl -n kube-system rollout status deployment aws-load-balancer-controller'
                        sh 'kubectl apply -f ./eks/k8s/ingress.yaml'
                    }
                }
            }
        }    
    }
}