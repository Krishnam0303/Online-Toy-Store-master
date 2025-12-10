pipeline {
  agent any
  environment {
    APP_HOST = "ubuntu@98.93.96.181"
    SSH_CRED_ID = "ec2-app-ssh"
    IMAGE_NAME = "online-toy-store"
    IMAGE_TAG = "build-${env.BUILD_ID}"
    TAR_FILE = "image-${env.BUILD_ID}.tar"
  }

  stages {

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build') {
      steps {
        script {
          if (fileExists('pom.xml')) {
            sh 'mvn -B -DskipTests package'
          }
          sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
        }
      }
    }

    stage('Save & Transfer') {
      steps {
        sh "docker save ${IMAGE_NAME}:${IMAGE_TAG} -o ${TAR_FILE}"
        sshagent (credentials: [SSH_CRED_ID]) {
          sh "scp -o StrictHostKeyChecking=no ${TAR_FILE} ${APP_HOST}:~/"
        }
      }
    }

    stage('Deploy on App Host') {
      steps {
        sshagent (credentials: [SSH_CRED_ID]) {
          sh """
            ssh -o StrictHostKeyChecking=no ${APP_HOST} '
              docker load -i ~/${TAR_FILE} || exit 1 &&
              docker stop toy-app || true &&
              docker rm toy-app || true &&
              docker run -d --name toy-app -p 80:8080 ${IMAGE_NAME}:${IMAGE_TAG}
            '
          """
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: "${TAR_FILE}", allowEmptyArchive: true
    }
  }
}
