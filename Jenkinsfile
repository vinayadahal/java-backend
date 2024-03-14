pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS= credentials('docker-hub-credentials')
    }

    stages {
        stage('Docker Build') {
            steps {
                script {
                    def branch_name=env.BRANCH_NAME
                    if (branch_name == "main") {
                        echo "Building docker image with 'latest' tag"
                        sh 'docker build -t bidahal/nodejs-back .'
                    } else if (branch_name == "stg") {
                        echo "Building docker image with 'stg' tag"
                        sh 'docker build -t bidahal/nodejs-back:stg .'
                    } else if (branch_name == "dev") {
                        echo "Building docker image with 'dev' tag"
                        sh 'docker build -t bidahal/nodejs-back:dev .'
                    } else {
                        echo "Building docker image without a tag for feature branch: $branch_name"
                        sh 'docker build -t bidahal/nodejs-back .'
                    }
                }
            }
        }
        stage('Docker Login and Push') {
            steps {
                script {
                    def branch_name=env.BRANCH_NAME
                    if (branch_name == "main") {
                        echo "Logging into docker hub and pushing the changes to 'main' tag"
                        sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                        sh 'docker push bidahal/nodejs-back'
                    } else if (branch_name == "stg") {
                        echo "Logging into docker hub and pushing the changes to 'stg' tag"
                        sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                        sh 'docker push bidahal/nodejs-back:stg'
                    } else if (branch_name == "dev") {
                        echo "Logging into docker hub and pushing the changes to 'dev' tag"
                        sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                        sh 'docker push bidahal/nodejs-back:dev'
                    } else {
                        echo "Skipping docker login and push for feature branch: $branch_name..."
                    }
                }
            }
        }
        stage('Deploy k8s') {
            steps {
                script {
                    def branch_name=env.BRANCH_NAME
                    if (branch_name == "main") {
                        echo "Applying changes to the main k8s cluster"
                        sh 'kubectl apply -f k8s/deploy-backend.yml'
                        sh 'kubectl apply -f k8s/hpa.yml'
                    } else if (branch_name == "stg") {
                        echo "Applying changes to the main k8s cluster for stg branch"
                        sh 'kubectl apply -f k8s/deploy-backend-stg.yml'
                        sh 'kubectl apply -f k8s/hpa-stg.yml'
                    } else if (branch_name == "dev") {
                        echo "Applying changes to the main k8s cluster for dev branch"
                        sh 'kubectl apply -f k8s/deploy-backend-dev.yml'
                        sh 'kubectl apply -f k8s/hpa-dev.yml'
                    } else {
                        echo "Skipping deploy for feature branch: $branch_name..."
                    }
                }
            }
        }
        stage('Deploy latest image') {
            steps {
                script {
                    def branch_name=env.BRANCH_NAME
                    if (branch_name == "main") {
                        echo "Replace image in the cluster for main branch"
                        sh 'kubectl set image deployment/adex-webapp-backend-deployment adex-webapp-backend-pod=bidahal/nodejs-back:latest -n adex-webapp'
                    } else if (branch_name == "stg") {
                        echo "Replace image in the cluster for stg branch"
                        sh 'kubectl set image deployment/adex-webapp-backend-deployment-stg adex-webapp-backend-pod-stg=bidahal/nodejs-back:stg -n adex-webapp-stg'
                    } else if (branch_name == "dev") {
                        echo "Replace image in the cluster for dev branch"
                        sh 'kubectl set image deployment/adex-webapp-backend-deployment-dev adex-webapp-backend-pod-dev=bidahal/nodejs-back:dev -n adex-webapp-dev'
                    } else {
                        echo "Skipping deploy for feature branch: $branch_name..."
                    }
                }
            }
        }
    }
}