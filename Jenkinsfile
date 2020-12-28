pipeline {
  agent {
    kubernetes {
      inheritFrom 'backend'
    }
  }

  environment {
    ECR_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/dev/tomcat-app"
  }

  stages {
    stage('Pull Artifact') {
      steps {
        sh "curl -o sample.war https://tomcat.apache.org/tomcat-8.0-doc/appdev/sample/sample.war"
      }
    }
    stage('Build image') {
      steps {
        sh '''
          docker build -t dev/tomcat-app .
          docker tag dev/tomcat-app:latest ${ECR_URL}:latest
        '''
      }
    }
    stage('Push image') {
      steps {
        sh '''
          aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
          docker push ${ECR_URL}:latest
        '''
      }
    }
    stage('Deploy') {
      steps {
        sh '''
          ./deploy.sh "${ECR_URL}" "${ALB_INGRESS_SG_ID}" "${ACM_ARN}" "${DOMAIN_NAME}"
        '''
      }
    }
  }
}
