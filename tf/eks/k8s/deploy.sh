kubectl apply -f ./namespaces.yaml
kubectl apply configmap env --from-env-file=.env.local --namespace=app
kubectl apply -k secrets
kubectl apply -f ./mongo.yaml
kubectl apply -f ./postgres-storage.yaml
kubectl apply -f ./postgresql.yaml
kubectl apply -f ./api.yaml
kubectl apply -f ./ui.yaml
kubectl apply -f HPA.yaml
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"