pipeline {
    agent any

    environment {
        IMAGE_NAME = "krtech26/mydocker26"
        TAG = "${BUILD_NUMBER}"
        AWS_REGION = "ap-south-1"
        CLUSTER_NAME = "my-eks-cluster"
    }

    stages {

        stage('Clone') {
            steps {
                git branch: 'main', url: 'https://github.com/kamal261292/eksproject.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${TAG} ."
                }
            }
        }


        stage('Push to DockerHub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'Dockerhub',
                        usernameVariable: 'DOCKERHUB_USERNAME',
                        passwordVariable: 'DOCKERHUB_PASSWORD'
                    )
                ]) {
                    sh """
                        echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin
                        docker push ${IMAGE_NAME}:${TAG}
                        docker logout
                    """
                }
            }
        }

        stage('Provision EKS with Terraform') {
            steps {
                dir('terraform') {
                    withCredentials([
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWSID']
                    ]) {
                        withEnv(["AWS_DEFAULT_REGION=${env.AWS_REGION}"]) {
                            sh '''
                                terraform init
                                terraform apply -auto-approve
                            '''
                        }
                    }
                }
            }
        }

        stage('Configure kubectl') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWSID']
                ]) {
                    sh '''
                        aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh """
                    kubectl apply -f k8s/deployment.yml
                    kubectl apply -f k8s/service.yml
                """
            }
        }
    }

    post {
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
