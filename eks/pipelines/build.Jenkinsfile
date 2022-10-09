@Library('lib')_

pipeline {
    agent {
        label 'agent2'
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('hnom_docker-hub')
    }

    stages {
        stage('Download env files') {
            // Downloading files with environment variables
            steps {
                script{
                    utils.print("Message")
                }
                withAWS(credentials: "Amazon creds", region: "eu-central-1"){
                    sh 'aws s3 cp s3://env-files-dca231321f31/.env.local ./OleksandrHavron/src/etc/.env.local'
                    sh 'aws s3 cp s3://env-files-dca231321f31/.env ./OleksandrHavron/src/codeArena/.env'
                }
            }
        }
        stage('Build') {
            // Building images
            steps {
                dir("./OleksandrHavron/src"){
                    sh 'docker-compose build'
                }
            }
        }
        stage('Login') {
            // Log in to dockerhub
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
        stage('Push'){
            // Upload images to Docker Hub
            steps{
                sh 'docker push hnom/codearena-api:latest'
                sh 'docker push hnom/codearena-ui:latest'
            }
        }
    }
    post {
        always {
            sh 'docker logout'
        }
    }
}
