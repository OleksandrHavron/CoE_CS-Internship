### EKS cluster setup
1. Make sure you have installed AWS CLI or eksctl (better to use), kubectl on your local machine 
2. Using AWS EKS, set up a new cluster with the name NewcomerName-cluster
3. Create an additional node group in your cluster
    >node-type: t3.medium </br>
    >nodes: 4 
4. Set up namespaces: app and monitoring 
5. Set up deployment with a simple application. 

    >Use app namespace for every app pod. 
 If your application requires additional components (front and backend, database, Redis, etc) – please create an appropriate Deployment for each one. 

6. Provide a horizontal application scaling based on CPU or RAM utilization 
7. Set up Secrets and Configmap. 
8. Set up Services for network communication between all components 
9. Set up an ingress controller 
10. Set up external DNS for your app 
11. Provide health checks  (liveness and readiness probes)  for all your deployments 