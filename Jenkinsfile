pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        ECR_REPO = "703671928278.dkr.ecr.ap-south-1.amazonaws.com/online-toy-store"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'master',
                url: 'https://github.com/Krishnam0303/Online-Toy-Store-master.git'
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                sh '''
                docker run --rm \
                -v $PWD:/src \
                owasp/dependency-check \
                --scan /src \
                --format HTML \
                --out /src/reports
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $ECR_REPO:$IMAGE_TAG .
                docker tag $ECR_REPO:$IMAGE_TAG $ECR_REPO:latest
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${ECR_REPO%%/*}
                docker push $ECR_REPO:$IMAGE_TAG
                docker push $ECR_REPO:latest
                '''
            }
        }
    }
}
